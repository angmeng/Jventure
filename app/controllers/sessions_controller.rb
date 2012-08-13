class SessionsController < ApplicationController
  
  def new
  end
  
  def create

      user = User.authenticate(params[:txtLoginID], params[:txtPassword])
      if user
        session[:user_id] = user.id
        flash[:notice] = "Logged in successfully."
        redirect_to_target_or_default(member_area_url)
      else
        flash.now[:error] = "Invalid login or password."
        render :action => 'new'
      end

  end

  def new_agent

  end

  def create_agent
    agent = Agent.authenticate(params[:txtLoginID], params[:txtPassword])
      if agent
        if agent.process_login_record(request.remote_ip)
          session[:agent_id] = agent.id
          flash[:notice] = "Logged in successfully."
          redirect_to_target_or_default(member_area_url)
        else
          flash.now[:error] = "You login has been freezed"
          render :action => 'new_agent'
        end
      else
        flash.now[:error] = "Invalid login or password."
        render :action => 'new_agent'
      end
  end
  
  def destroy
    begin
      if is_admin?
        clear_sessions
        flash[:notice] = "You have been logged out"
        redirect_to login_url
      elsif is_agent?
        LoginRecord.create(:agent_id => session[:agent_id], :ip_address => request.ip,:item_category_id => LoginRecord::LOGOUT)
        clear_sessions
        flash[:notice] = "You have been logged out"
        redirect_to home_url
      end
    rescue
      flash[:notice] = "You have been logged out"
      redirect_to home_url
    end
  end
  
  def unauthorized
    if is_admin?
      clear_sessions
      flash[:error] = "Unauthorized access"
      redirect_to login_url
    else
      clear_sessions
      flash[:error] = "Unauthorized access"
      redirect_to agency_url
    end
  end
  
  private
  
  def clear_sessions
      session[:user_id] = nil
      session[:agent_id] = nil
      session[:proposal_agent_id] = nil
      session[:from] = nil
      session[:to] = nil
      session[:level_id] = nil
      session[:upline_id] = nil
  end



end
