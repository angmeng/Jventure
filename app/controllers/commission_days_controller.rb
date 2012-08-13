class CommissionDaysController < ApplicationController
  before_filter :authenticated_admin
  # GET /commission_days
  # GET /commission_days.xml
  def index
    @commission_days = CommissionDay.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @commission_days }
    end
  end

  # GET /commission_days/1
  # GET /commission_days/1.xml
  def show
    @commission_day = CommissionDay.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @commission_day }
    end
  end

  # GET /commission_days/new
  # GET /commission_days/new.xml
  def new
    @commission_day = CommissionDay.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @commission_day }
    end
  end

  # GET /commission_days/1/edit
  def edit
    @commission_day = CommissionDay.find(params[:id])
  end

  # POST /commission_days
  # POST /commission_days.xml
  def create
    @commission_day = CommissionDay.new(params[:commission_day])

    respond_to do |format|
      if @commission_day.save
        format.html { redirect_to(@commission_day, :notice => 'CommissionDay was successfully created.') }
        format.xml  { render :xml => @commission_day, :status => :created, :location => @commission_day }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @commission_day.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /commission_days/1
  # PUT /commission_days/1.xml
  def update
    @commission_day = CommissionDay.find(params[:id])

    respond_to do |format|
      if @commission_day.update_attributes(params[:commission_day])
        format.html { redirect_to(@commission_day, :notice => 'CommissionDay was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @commission_day.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /commission_days/1
  # DELETE /commission_days/1.xml
  def destroy
    @commission_day = CommissionDay.find(params[:id])
    if @commission_day.verify_destroy
      flash[:notice] = "Destroy successfully"
    else
      flash[:error] = "Commission day cannot be destroy"
    end
    respond_to do |format|
      format.html { redirect_to(commission_days_url) }
      format.xml  { head :ok }
    end
  end
end
