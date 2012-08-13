class SubCommissionsController < ApplicationController
  before_filter :authenticated_admin
  # GET /sub_commissions
  # GET /sub_commissions.xml
  def index
    @sub_commissions = SubCommission.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sub_commissions }
    end
  end

  # GET /sub_commissions/1
  # GET /sub_commissions/1.xml
#  def show
#    @sub_commission = SubCommission.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.xml  { render :xml => @sub_commission }
#    end
#  end

  # GET /sub_commissions/new
  # GET /sub_commissions/new.xml
  def new
    @sub_commission = SubCommission.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sub_commission }
    end
  end
#
#  # GET /sub_commissions/1/edit
  def edit
    @sub_commission = SubCommission.find(params[:id])
  end
#
#  # POST /sub_commissions
#  # POST /sub_commissions.xml
  def create
    @sub_commission = SubCommission.new(params[:sub_commission])

    respond_to do |format|
      if @sub_commission.save
        flash[:notice] = 'Recruitment Incentive was successfully created.'
        format.html { redirect_to(sub_commissions_url) }
        format.xml  { render :xml => @sub_commission, :status => :created, :location => @sub_commission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sub_commission.errors, :status => :unprocessable_entity }
      end
    end
  end
#
#  # PUT /sub_commissions/1
#  # PUT /sub_commissions/1.xml
  def update
    @sub_commission = SubCommission.find(params[:id])

    respond_to do |format|
      if @sub_commission.update_attributes(params[:sub_commission])
        flash[:notice] = 'Recruitment Incentive was successfully updated.'
        format.html { redirect_to(@sub_commission.plan) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sub_commission.errors, :status => :unprocessable_entity }
      end
    end
  end
#
#  # DELETE /sub_commissions/1
#  # DELETE /sub_commissions/1.xml
  def destroy
    @sub_commission = SubCommission.find(params[:id])
    @sub_commission.destroy
    @plan = @sub_commission.plan

    render :update do |page|
      page.replace_html 'supplementary', :partial => '/plans/supplementary'
    end
  end
end
