class AgentsController < ApplicationController
   before_filter :authenticated_admin_and_agent
   before_filter :registration_session, :only => [:show_popup_hierarchy, :show_hierarchy, :show_tree, :show_downlines, :destroy, :create, :new_topup, :update, :edit, :create_topup]


  def index
    if is_admin?
      @search = Agent.search(params[:search])
      @agents = @search.all(:select => "id, fullname, code, upline_id, new_ic_number", :include => [:upline]).paginate(:page => params[:page], :per_page => 30)
    else
      setting = Setting.first
      if setting.agent_open_registration_level == Setting::DISABLE
        @search = Agent.search(params[:search])
        @agents = []
        @agents = @agents.paginate(:page => params[:page], :per_page => 30)
      elsif setting.agent_open_registration_level == Setting::DIRECT_ONLY
        @search = Agent.search(params[:search])
        @search = @search.upline_id_equals(session[:agent_id])
        @agents = @search.all(:select => "id, fullname, code, upline_id, new_ic_number", :include => [:upline]).paginate(:page => params[:page], :per_page => 30)
      elsif setting.agent_open_registration_level == Setting::OPEN
        @search = Agent.search(params[:search])
        agents = @search.all
        agent = Agent.find(session[:agent_id])
        filtered = agent.filter(agents)
        @agents = filtered.paginate(:page => params[:page], :per_page => 30)
      end
      
    end
  end

  def contact
    if is_admin?
      
      respond_to do |wants|
        wants.html {
          @agents = Agent.all(:order => "code", :include => :upline).paginate(:page => params[:page], :per_page => 30)
          }
        wants.pdf { 
          output = Report.new.contact
           send_data output, :filename => "contact.pdf", 
                             :type => "application/pdf",
                             :disposition  => "inline"
          }
      end
    end
  end
  
  def show
    @agent = Agent.find(params[:id])
    @first, @last, @next, @previous =  Agent.next_previous_label(@agent.id)
    #@result = @agent.all_expiry_date
    if @agent.id == @first.id
      flash.now[:notice] = "This is the first agent in database"
    elsif @agent.id == @last.id
      flash.now[:notice] = "This is the last agent in database"
    end
    
    respond_to do |wants|
      wants.html
      wants.pdf {
        output = Report.new.to_pdf
        send_data output, :filename => "hello.pdf", :type => "application/pdf", :disposition  => 'inline'
      }
    end
    
  end


  def show_upline
    @uplines = Agent.all(:conditions => ['code LIKE ?', "#{params[:search]}%"])
    @uplines.each {|c|
      c.code = c.screen_name
    }
  end
  
  def new_topup
    if is_admin?
      @agent = Agent.find(params[:id])
      @proposal = Proposal.new
    end
  end
  
  def create_topup
    if request.post?
      @proposal = Proposal.new(params[:proposal])
      @proposal.has_proposer = false
      if @proposal.save
        flash[:notice] = "Topup has been created"
        redirect_to @proposal
      else
        @agent = Agent.find(params[:proposal][:investor_id].to_i)
        flash[:error] = "Please check again"
        render :action => "new_topup"
      end
    end
  end
  
  #def new
  #  if is_admin?
  #    @agent = Agent.new
  #  end
  #end
  
  def create
    @agent = Agent.new(params[:agent])
#    @agent.password = '123456'
#    @agent.password_confirmation = '123456'
    if @agent.save
      flash[:notice] = "Successfully created agent."
      redirect_to @agent
    else
      render :action => 'new'
    end
  end
  
  def edit
    if is_admin?
      @agent = Agent.find(params[:id])
    elsif is_agent?
      @agent = Agent.find(params[:id])
      redirect_to :controller => "sessions", :action => 'unauthorized' unless @agent.is_himself?(current_id)
    end

  end
  
  def update
    @agent = Agent.find(params[:id])
    if @agent.update_attributes(params[:agent])
      flash[:notice] = "Successfully updated agent."
      redirect_to @agent
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    if is_admin?
      @agent = Agent.find(params[:id])
      checked, msg = @agent.verify_destroy
      if checked
        flash[:notice] = msg
      else
        flash[:error] = msg
      end
    end
    
    redirect_to agents_url
  end

  def change_password
    if is_admin?
      @agent = Agent.find(params[:id])
    elsif is_agent?
      @agent = Agent.find(params[:id])
      redirect_to :controller => "sessions", :action => 'unauthorized' unless @agent.is_himself?(current_id)
    end
  end

  def update_password
    @agent = Agent.find(params[:id])

    passed, msg = @agent.check_password(params[:agent])

    if passed
      flash[:info] = msg
      redirect_to @agent
    else
      flash[:error] = msg
      render :action => "change_password"

    end
  end
  
  def show_downlines
    
    if params[:id]
      @agent = Agent.find(params[:id])
      session[:upline_id] = @agent.id

      if params[:level_id]
        session[:level_id] = params[:level_id]
        @results = @agent.collect_downlines(params[:level_id].to_i)
        @agents = @results.paginate(:page => params[:page], :per_page => 30)
      else
        @results = @agent.collect_downlines(0)
        @agents = @results.paginate(:page => params[:page], :per_page => 30)
      end

    else
        @agent ||= Agent.find(session[:upline_id].to_i)
        @results ||= @agent.collect_downlines(session[:level_id].to_i)
        @agents = @results.paginate(:page => params[:page], :per_page => 30)
    end
        
  end
  
  def show_tree
    @agent = Agent.find(params[:id])
    #@target = Agent.find(params[:search_agent_id])
    #@agent.collect_hierarchy
  end
  
  def show_hierarchy
    @agent = Agent.find(params[:id])
    @target = Agent.find(params[:search_agent_id])
    #@agent.collect_hierarchy
  end

  def show_popup_hierarchy
    @agent = Agent.find(params[:id])
    #@target = Agent.find(params[:search_agent_id])
    #@agent.collect_hierarchy
#    render :layout => false
    render :update do |page|
      case params[:level_id].to_i
      when 0
        page.show 'level00'
        page.replace_html 'level00', :partial => "show_popup_hierarchy", :locals => {:agent => @agent}
        page.visual_effect :highlight, 'level00'

      when 1
        page.show 'level11'
        page.replace_html 'level11', :partial => "show_popup_hierarchy", :locals => {:agent => @agent}
        page.visual_effect :highlight, 'level11'

      when 2
        page.show 'level22'
        page.replace_html 'level22', :partial => "show_popup_hierarchy", :locals => {:agent => @agent}
        page.visual_effect :highlight, 'level22'

      when 3
        page.show 'level33'
        page.replace_html 'level33', :partial => "show_popup_hierarchy", :locals => {:agent => @agent}
        page.visual_effect :highlight, 'level33'

      when 4
        page.show 'level44'
        page.replace_html 'level44', :partial => "show_popup_hierarchy", :locals => {:agent => @agent}
        page.visual_effect :highlight, 'level44'

      end
      
      #page.hide 'status-indicator', 'cancel-link'
    end
  end

  private

  def registration_session
    if Setting.first.block_registration?
      flash[:error] = "Action not allow. Commission is generating ... "
      redirect_to :action => 'index'
    end
  end


end
