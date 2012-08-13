class ProposalsController < ApplicationController
  before_filter :authenticated_admin_and_agent
  before_filter :registration_session, :only => [:new, :create, :cancel, :get_approval, :update, :edit, :cancellation_date, :convert_life_assured, :convert_proposer, :add_agent_to_proposal, :add_agent_to_proposer]
   
  def index
    if is_admin?
      @last_date = Setting.first.last_expiry_check_date
      @search = Proposal.yet_approved_proposals.search(params[:search])
      @proposals = @search.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    else
      @search = Proposal.yet_approved_proposals.search(params[:search])
      @search = @search.agent_id_equals(session[:agent_id])
      @proposals = @search.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    end
  end
  
  def show_payment_info
    payment = PaymentMethod.find(params[:id]) if params[:id] rescue nil

    render :update do |page|
      if payment.name.include?("Credit Card")
        page.show 'payment_info'
      else
        page.hide 'payment_info'
      end if payment
    end
  end

  def policy
    if is_admin?
      @search = Proposal.approved_proposals.search(params[:search])
      @search.investor_id_equals = Proposal.agent_searching_name(params[:investor][:name]) if params[:investor] && params[:investor][:name] != ""
      @proposals = @search.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    else
      @search = Proposal.approved_proposals.search(params[:search])
      @search = @search.agent_id_equals(session[:agent_id])
      @proposals = @search.all(:order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    end
  end
  
  def show
    @proposal = Proposal.find(params[:id])
    @first, @last, @next, @previous =  Proposal.next_previous_label(@proposal.id)
    if @proposal.id == @first.id
      flash.now[:notice] = "This is the first proposal in database"
    elsif @proposal.id == @last.id
      flash.now[:notice] = "This is the last proposal in database"
    end
  end

  def show_agent
    @agents = Agent.all(:conditions => ['code LIKE ?', "#{params[:search]}%"])
    @agents.each {|c|
      c.code = c.screen_name
    }
  end

  def edit
    @proposal = Proposal.find(params[:id])
  end
  
  def update
    @proposal = Proposal.find(params[:id])
    @proposal.policy_number = params[:proposal][:policy_number] if params[:proposal][:policy_number]
    if @proposal.update_attributes(params[:proposal])
      flash[:notice] = "Successfully updated proposal."
      redirect_to @proposal
    else
      render :action => 'edit'
    end
  end

  def get_approval
    if is_admin?
      @proposal = Proposal.find(params[:id])
      if @proposal.approved
        flash[:error] = "The proposal is already approved before"
        redirect_to @proposal
      else
        begin
          raise "policy number not entered" if params[:policy_number].blank?
          @proposal.policy_number = params[:policy_number].strip
          @proposal.approval_date = Date.parse(params[:approval_date])
          @proposal.approved = true
          if @proposal.save(false)
            #@proposal.calculate_base_commission
            flash[:info] = "Proposal has been successfully approved"
          else
            flash[:error] = "Please check the proposal in detail, there is some field haven't fill up"
          end
          redirect_to @proposal
        rescue
          flash[:error] = "Please check your approval date and approval number"
          redirect_to @proposal
        end
    
      end
    end
  end

  def commission_detail
    @proposal = Proposal.find(params[:id])
    @commissions = @proposal.all_commission_transactions
  end

  def cancellation_date
    @proposal = Proposal.find(params[:id])
  end
  
  def cancel
    if is_admin?
      proposal = Proposal.find(params[:id])
      if params[:cancel_date].blank?
        flash[:error] = "Please choose a valid date"
        redirect_to cancellation_date_proposal_path(proposal)
      else
        proposal.verify_destroy(Date.parse(params[:cancel_date]).to_s)
        flash[:notice] = "Successfully canceled proposal"
        redirect_to proposal
      end
    end
    
  end

  def convert_life_assured
    proposal = Proposal.find(params[:id])
    proposal.convert_life_assured
    flash[:notice] = "Conversion completed"
    redirect_to(proposal)
  end

  def convert_proposer
    proposal = Proposal.find(params[:id])
    proposal.convert_proposer
    flash[:notice] = "Conversion completed"
    redirect_to(proposal)
  end

  def new
    if is_admin? 
      @proposal = Proposal.new
    elsif is_master_agent?
      if current_user.can_add_proposal?
        @proposal = Proposal.new
      else
        flash[:error] = "Sorry, you dont have enough credits"
        redirect_to proposals_path
      end
    end
  end

  def add_agent_to_proposal
    agent = Agent.find(params[:id])
    @proposal = Proposal.convert_from(agent)
    render :template => 'agents/new_client'
  end
  
  def add_agent_to_proposer
    agent = Agent.find(params[:id])
    @proposal = Proposal.convert_to(agent)
    render :template => 'agents/new_client'
  end

  def create
    @proposal = Proposal.new(params[:proposal])
    
    if is_agent?
      if current_user.credits < @proposal.modal_premium
        flash[:error] = "You dont have enough credit"
        render :action => 'new' 
      else
         if @proposal.saving_proposal
           flash[:notice] = "Proposal successfully created"
           if params[:commit] == "Submit"
             redirect_to(@proposal)
           elsif params[:commit] == "Submit and Continue"
             redirect_to new_proposal_path
           end
         else
           render :action => 'new'
         end
      end
    elsif is_admin?
       if @proposal.saving_proposal
          flash[:notice] = "Proposal successfully created"
          if params[:commit] == "Submit"
            redirect_to(@proposal)
          elsif params[:commit] == "Submit and Continue"
             redirect_to new_proposal_path
          end 
       else
          render :action => 'new'
       end
    end
  end

  def show_payment_info
    payment = PaymentMethod.find(params[:id]) if params[:id] rescue nil

    render :update do |page|
      if payment.name == "Credit Card"
        page.show 'payment_info'
      else
        page.hide 'payment_info'
      end if payment
    end
  end

  def check_expiry_date
    count = Engineer.check_expiry_of_proposals
    if count > 0
      flash[:notice] = "Operation Completed. You have " + count.to_s + " expired policy. Please go to renewal to manage them."
    else
      flash[:notice] = "Operation Completed. You have " + count.to_s + " expired policy"
    end
    redirect_to :action => "index"
  end

  def agent_info
  end

  def check_agent
    if params[:agent_code].blank? or params[:check_date].blank?
      flash[:error] = "You need to enter an agent code and check date to check"
      redirect_to agent_info_proposals_path
    else
      check_date = Date.parse(params[:check_date]) rescue nil
      @agent = Agent.find_by_code(params[:agent_code].strip)
      if @agent and check_date
        redirect_to show_agent_qualification_proposal_path(@agent, :check_date => check_date.to_s)
      else
        flash[:error] = "Agent cannot be found or check date is invalid"
        redirect_to agent_info_proposals_path
      end
    end
  end

  def show_agent_qualification
    @agent = Agent.find(params[:id])
    @downlines = @agent.sales
    @check_date = Date.parse(params[:check_date])
    
  end

    private

  def registration_session
    if Setting.first.block_registration?
      flash[:error] = "Action not allow. Commission is generating ... "
      redirect_to :action => 'index'
    end
  end

end
