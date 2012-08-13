class UsersController < ApplicationController
  before_filter :authenticated_admin
  
  def index
    if is_admin?
      @users = User.paginate(:page => params[:page], :per_page => 20, :order => "username")
    elsif is_agent?
      @users = User.all(:conditions => ["id = ? ", session[:agent_id]]).paginate(:page => params[:page], :per_page => 20, :order => "username")
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated sucessfully"
      redirect_to @user
    else
      flash[:error] = "Error!"
      render :action => "edit"
      
    end
  end
  
  def change_password
    @user = User.find(params[:id])
  end
  
  def update_password
    @user = User.find(params[:id])
    
    passed, msg = @user.check_password(params[:user])
    
    if passed
      flash[:notice] = msg
      redirect_to @user
    else
      flash[:error] = msg
      render :action => "change_password"
      
    end
  end
  
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "User created successfully"
      redirect_to @user
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    
    passed, msg = @user.verify_destroy
    if passed
      flash[:notice] = msg
    else
      flash[:error] = msg
    end
    redirect_to users_url
  end


  def profile
    @user = User.find(params[:id])
    if request.put? or request.post?
      if params[:user][:password].blank? and params[:user][:password_confirmation].blank?
        
        @user.fullname = params[:user][:fullname]
        @user.username = params[:user][:username]
        @user.email = params[:user][:email]
        @user.save!
        flash[:notice] = "Upadated successfully"
        redirect_to profile_user_path(@user)
      else

        checked, msg = @user.check_password(params[:user])
        if checked
          flash[:notice] = msg
        else
          flash[:error] = msg
        end
        redirect_to profile_user_path(@user)
      end
    end
    
  end
  
end
