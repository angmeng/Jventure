class CommissionsController < ApplicationController
  before_filter :authenticated_admin
  
  def index
    @commissions = Commission.all
  end
  
  def show
    @commission = Commission.find(params[:id])
  end
  
  def new
    @commission = Commission.new
  end
  
  def create
    @commission = Commission.new(params[:commission])
    if @commission.save
      flash[:notice] = "Successfully created commission."
      redirect_to @commission
    else
      render :action => 'new'
    end
  end
  
  def edit
    @commission = Commission.find(params[:id])
  end
  
  def update
    @commission = Commission.find(params[:id])
    if @commission.update_attributes(params[:commission])
      flash[:notice] = "Successfully updated commission."
      redirect_to @commission
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @commission = Commission.find(params[:id])
    @commission.destroy
    flash[:notice] = "Successfully destroyed commission."
    redirect_to commissions_url
  end
end
