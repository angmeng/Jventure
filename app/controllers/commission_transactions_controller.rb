class CommissionTransactionsController < ApplicationController
  before_filter :authenticated_admin_and_agent

  def index

    if params[:search] 
        if params[:from].blank? and params[:to].blank?
          flash[:error] = "Please choose a valid date"
          @search = CommissionTransaction.search(params[:search])
          @commission_transactions = @search.all(:order => "date_paid DESC, level_paid", :limit => 0, :joins => [:proposal, :agent])

        else
          from = Date.parse(params[:from]).to_s rescue from = Date.today.to_s
          to = Date.parse(params[:to]).to_s rescue to = Date.today.to_s
          @search = CommissionTransaction.query_date(from, to).search(params[:search])
          @commission_transactions = @search.all(:order => "date_paid DESC, level_paid", :joins => [:proposal, :agent])
          @total = CommissionTransaction.sum_total(@search.all)
          #@miscellaneous = MiscellaneousItem.agent_misc(params[:search][:agent_id_equals].to_i, from, to)
        end
    else
      @search = CommissionTransaction.search(params[:search])
      @commission_transactions = [] #@search.all(:order => "date_paid DESC", :limit => 0)
    end
    #@agents = Agent.all(:order => "code")
  end
  
  def regenerate
    
    begin
      com_generation = CommissionGeneration.find(params[:id])
      @month = com_generation.generate_date.month.to_s
      @year  = com_generation.generate_date.year.to_s
      params[:option] ||= []
      if params[:option].size.to_i > 0
        @comm_days = []
        params[:option].each do |item_id, content|
          found = CommissionDay.find(item_id.to_i) #if content[:selected]
          @comm_days << found if found
        end
        MiscellaneousItem.destroy_items(com_generation.generate_date.beginning_of_month, com_generation.generate_date.end_of_month)
        CommissionTransaction.destroy_items(com_generation.generate_date.beginning_of_month, com_generation.generate_date.end_of_month)
        @comm_days = @comm_days.sort_by {|c| c.id}
        @msg = ""
        generate_commission(true)
        flash[:notice] = @msg << "View the report by selecting from date to date of the month. "
        #CommissionTransaction.generate_agent_list(from, to, current_id)
        #redirect_to agent_list_commission_transactions_path
        redirect_to commission_date_commission_transactions_path
      else
        flash[:error] = "You must select at least one commission type to run"
        redirect_to commission_date_commission_transactions_path
      end

    #rescue Exception => exc
    #  flash[:error] = exc.message + " ! Please contact the Administrator"
    #  redirect_to commission_date_commission_transactions_path
    end
  end
  
  def commission_date
    @generations = CommissionGeneration.all(:order => "generate_date DESC", :group => "generate_date")
    #@generations = generations.group_by { |g| g.generate_date }
  end
  
  def view_report
    com_generation = CommissionGeneration.find(params[:id])
    from = com_generation.generate_date.beginning_of_month
    to = com_generation.generate_date.end_of_month
    session[:from] = from
    session[:to] = to
    CommissionTransaction.generate_agent_list(from, to, current_id)
    redirect_to agent_list_commission_transactions_path
  end
  
  def report_date
    com_generation = CommissionGeneration.find(params[:id])
    setup = com_generation.generate_date
    session[:from] = Date.parse(setup.year.to_s + "-" + setup.month.to_s + "-"  + params[:date][:from])
    session[:to] = Date.parse(setup.year.to_s + "-" + setup.month.to_s + "-"  + params[:date][:to])
    CommissionTransaction.generate_agent_list(session[:from], session[:to], current_id)
    redirect_to agent_list_commission_transactions_path
  end

  def calculate_sub
    begin
      @month = params[:date][:month]
      @year  = params[:date][:year]
      params[:option] ||= []
      if params[:option].size.to_i > 0
        @comm_days = []
        params[:option].each do |item_id, content|
          found = CommissionDay.find(item_id.to_i) #if content[:selected]
          @comm_days << found if found
        end
        @comm_days = @comm_days.sort_by {|c| c.id}
        @msg = ""
        generate_commission(false)
        flash[:notice] = @msg << "View the report by selecting from date to date of the month. "
        #CommissionTransaction.generate_agent_list(from, to, current_id)
        #redirect_to agent_list_commission_transactions_path
        redirect_to commission_date_commission_transactions_path
      else
        flash[:error] = "You must select at least one commission type to run"
        redirect_to commission_date_commission_transactions_path
      end
              
    #rescue Exception => exc
    #  flash[:error] = exc.message + " ! Please contact the Administrator"
    #  redirect_to commission_date_commission_transactions_path
    end
  end

  def agent_list
    if is_admin?
      @agents = current_user.commission_reports
      respond_to do |wants|
        wants.html 
        wants.pdf {
          output = Report.new(:page_size => "A4", :page_layout => :landscape).agent_list(@agents, session[:from], session[:to])
          send_data output, :filename => "agent_list.pdf", 
                            :type => "application/pdf",
                            :disposition  => "inline" 
         }
      end 
    end
  end

  def preview
      @agent = Agent.find(params[:id].to_i)
      @standard_commissions = CommissionTransaction.basic_paid(@agent.id).query_date(session[:from], session[:to]).all(:order => "date_paid DESC, level_paid")
      @overriding_commissions = CommissionTransaction.level_paid(@agent.id).query_date(session[:from], session[:to]).all(:order => "date_paid DESC, level_paid")
      @total = CommissionTransaction.sum_both_total(@standard_commissions, @overriding_commissions)
      @miscellaneous = MiscellaneousItem.agent_misc(@agent.id, session[:from], session[:to])
      render :layout => false
  end

  def remove_agent
    CommissionReport.remove_agent(params[:id])
    flash[:notice] = "Agent removed"
    redirect_to :action => "agent_list"
  end

  def show_detail
    @results = CommissionGeneration.all(:conditions => ["generate_date = ?", params[:generate_date]])
    missing_days = @results.select {|r| r.commission_day.nil? }
    if missing_days.empty?
      render :update do |page|
        page.replace_html 'detail', :partial => 'detail' #, :object => @person
      end
    else
      render :update do |page|
        page.replace_html 'detail', :partial => 'regenerate_detail' #, :object => @person
      end
    end
  end

  def regenerate_commission_days
    com_generation = CommissionGeneration.find(params[:id])
    generate_date = com_generation.generate_date
    com_generation.destroy
    if params[:option].to_i == 1
      CommissionDay.all.each do |c|
        unless CommissionGeneration.first(:conditions => ["generate_date = ? and commission_day_id = ?", generate_date,  c.id])
          CommissionGeneration.create!(:generate_date => generate_date, :commission_day_id => c.id)
        end
      end
    end
    @results = CommissionGeneration.all(:conditions => ["generate_date = ?", generate_date])
    render :update do |page|
      page.replace_html 'detail', :partial => 'detail' #, :object => @person
    end
  end

  def agent
    
    if params[:search]
      if params[:from].blank? and params[:to].blank?
        flash[:error] = "Please choose a valid date"
        @search = CommissionTransaction.search(params[:search])
        @commission_transactions = @search.all(:limit => 0)
          
      else
        session[:from] = Date.parse(params[:from]).to_s rescue session[:from] = Date.today.to_s
        session[:to] = Date.parse(params[:to]).to_s rescue session[:to] = Date.today.to_s

        @search = CommissionTransaction.query_date(session[:from], session[:to]).search(params[:search])
        @search = @search.agent_id_equals(session[:agent_id])
        @commission_transactions = @search.all(:order => "date_paid DESC")
        @total = CommissionTransaction.sum_total(@commission_transactions)
        @miscellaneous = MiscellaneousItem.agent_misc(session[:agent_id], session[:from], session[:to])
      end
    else
      @search = CommissionTransaction.search(params[:search])
      @commission_transactions = @search.all(:order => "date_paid DESC", :limit => 0)
    end
  end

  def print_agent
     begin
      @agent = Agent.find(session[:agent_id].to_i)

      standard_commissions_search = CommissionTransaction.query_date(session[:from], session[:to]).search(params[:search])
      overriding_commissions_search = CommissionTransaction.query_date(session[:from], session[:to]).search(params[:search])
      @standard_commissions = standard_commissions_search.level_paid_equals(0).all(:order => "date_paid DESC")
      @overriding_commissions = overriding_commissions_search.level_paid_greater_than(0).all(:order => "date_paid DESC")
      @total = CommissionTransaction.sum_both_total(@standard_commissions, @overriding_commissions)
      @miscellaneous = MiscellaneousItem.agent_misc(@agent.id, session[:from], session[:to])
      
      render :layout => false
    rescue
      flash[:error] = "Please choose an agent and the date period first, print the statement after click search button "
      redirect_to :action => 'agent'
    end
  end

  private

  def generate_commission(rerun)
    setting = Setting.first
    setting.block_registration = true
    setting.save!
    @comm_days.each do |comm_day|
      run_date = @year + "-" + @month + "-" + comm_day.from_calculate_day.to_s
      if comm_day.to_calculate_day == 31
        @to = Date.parse(run_date).end_of_month
      else
        @to = Date.parse(@year + "-" + @month + "-" + comm_day.to_calculate_day.to_s)
      end
      @from = Date.parse(run_date)

      if rerun
        calculate(comm_day)
        @msg << comm_day.description + " regenerated successfully. <br />"
      else
        found = CommissionGeneration.first(:conditions => ["Month(generate_date) = ? and Year(generate_date) = ? and commission_day_id = ?",@month.to_i, @year.to_i, comm_day.id])
        if found
          @msg << "Warning! " + comm_day.description + " is already generated before<br />"
        else
          CommissionGeneration.create(:generate_date => Date.parse(run_date).end_of_month, :commission_day_id => comm_day.id)
          calculate(comm_day)
          @msg << comm_day.description + " generated successfully. <br />"
        end
      end
    end
    setting.block_registration = false
    setting.save!
  end

  def calculate(comm_day)
    found_proposals = Proposal.requested_approvals(@from, @to)
    found_renewals  = ProposalApproval.requested_approvals(@from, @to)

    found_proposals.each do |p|
      if comm_day.basic_commission?
        p.calculate_base_commission(@to)
      end
      if comm_day.overriding_commission?
        p.calculate_overriding_commission(@to)
      end
    end
    if comm_day.renewal?
      found_renewals.each do |r|
        r.calculate_base_commission(@to)
        r.calculate_overriding_commission(@to)
      end
    end
  end


end
