class MemberAreaController < ApplicationController
  before_filter :authenticated_admin_and_agent
  
  def index
    @notices = BoardNotice.top_fifty_recent.paginate(:page => params[:page], :per_page => 3)
    if is_agent?
      @expiry  = ExpiringProposal.collect_report(current_id)
    end
  end

  def base_setup
  end

end
