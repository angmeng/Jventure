class PlansController < ApplicationController
  before_filter :authenticated_admin

  def index
    @plans = Plan.all
  end
  
  def show
    @plan = Plan.find(params[:id])
    
  end
  
  def remove_commission
    commission = Commission.find(params[:id])
    @plan = commission.plan
    commission.destroy
    flash[:notice] = "Operation completed"
    #redirect_to plan
    render :update do |page|
      page.replace_html 'commissions', :partial => '/plans/commissions'
    end
  end
  
  def submit_commission
    @plan = Plan.find(params[:id])
    @commission = @plan.commissions.new(params[:commission])

    if @commission.save
     flash[:notice] = "Operation Completed"
    end
      #redirect_to @plan
    render :update do |page|
      page.replace_html 'commissions', :partial => '/plans/commissions'
    end
  end

  def submit_supplementary
    @plan = Plan.find(params[:id])
    @supplementary = @plan.sub_commissions.new(params[:supplementary])

    if @supplementary.save
      flash[:notice] = "Operation Completed"
    end
    render :update do |page|
      page.replace_html 'supplementary', :partial => '/plans/supplementary'
    end
  end
  
  def new
    @plan = Plan.new
  end
  
  def create
    @plan = Plan.new(params[:plan])
    if @plan.save
      flash[:notice] = "Successfully created plan."
      redirect_to @plan
    else
      render :action => 'new'
    end
  end
  
  def edit
    @plan = Plan.find(params[:id])
  end
  
  def update
    @plan = Plan.find(params[:id])
    if @plan.update_attributes(params[:plan])
      flash[:notice] = "Successfully updated plan."
      redirect_to @plan
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @plan = Plan.find(params[:id])
    if @plan.verify_destroy
      flash[:notice] = "Successfully destroyed plan."
    else
      flash[:error] = "Th plan is in use and cannot be destroy"
    end
    redirect_to plans_url
  end
end
