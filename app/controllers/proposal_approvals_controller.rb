class ProposalApprovalsController < ApplicationController
  before_filter :authenticated_admin
  # GET /proposal_approvals
  # GET /proposal_approvals.xml
  def index
    @last_date = Setting.first.last_reminder_date
    @search = Proposal.search(params[:search])
    @proposals = ExpiringProposal.expired(@search.all)
    @proposals = @proposals.paginate(:page => params[:page], :per_page => 30)
  end

  # GET /proposal_approvals/1/edit
  def edit
    @proposal = Proposal.find(params[:id])
  end
  
  def renew
    proposal = Proposal.find(params[:id])
    if params[:approval_date].blank?
      flash[:error] = "Please select a proper date"
      redirect_to(proposal)
    else
      proposal.renew(params[:approval_date], params[:renewal_year])
      flash[:notice] = "Operation Completed"
      redirect_to(proposal)
    end
  end

  def send_reminder
    setting = Setting.first
    ExpiringProposal.all.each do |p|
      check = p.proposal.investor.email
      result = (check =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
      EmailNotification::deliver_reminder(p.proposal) if result and result == 0
    end
    
    EmailNotification::deliver_admin_reminder(setting.admin_email)
    flash[:notice] = "Reminder has been sent."
    Setting.first.update_attribute(:last_reminder_date, Date.today)
    redirect_to :action => 'index'
  end


end
