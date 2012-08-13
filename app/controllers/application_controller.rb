# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  helper_method :is_admin?
  helper_method :is_agent?
  helper_method :current_id
  helper_method :is_master_agent?

#  helper_method :current_user_department_id

  protected

  def authenticated_admin
    unless is_admin?
      
      redirect_to unauthorized_url
    end
  end

  def authenticated_admin_and_agent
    unless is_agent? or is_admin?
      
      redirect_to unauthorized_url
    end
  end

  def is_admin?
    session[:user_id]
  end
#
#
  def is_agent?
    session[:agent_id]
  end
  
  def is_master_agent?
    if is_agent?
      current_user.master_agent?
    else
      return false
    end
  end

  def current_id
    if is_admin?
      session[:user_id]
    elsif is_agent?
      session[:agent_id]
    end
  end


end
