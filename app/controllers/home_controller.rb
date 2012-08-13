class HomeController < ApplicationController
  
  def index
    @notices = BoardNotice.public.top_three_recent
  end

  def contact_us
  end

  def contact_submission
    
    if params[:guest_name].blank? or params[:email].blank? or params[:mobile].blank?
      flash[:error] = "Please fill in the necessary information"
      render :action => 'contact_us'
    else
      setting = Setting.first
      EmailNotification::deliver_notification(params[:guest_name], params[:email], params[:mobile], params[:comment])
      EmailNotification::deliver_admin_notification(setting.admin_email, params[:guest_name], params[:email], params[:mobile], params[:comment])
      flash[:notice] = "Thank you. Your information submited. We will contact you soon"
      redirect_to :action => 'contact_us'
    end
    
  end


  def notice
    @notice = BoardNotice.find(params[:id])
    
  end



end
