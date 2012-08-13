class ServicesChargersController < ApplicationController
  # GET /services_chargers
  # GET /services_chargers.xml
  def index
    @services_chargers = ServicesCharger.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @services_chargers }
    end
  end

  # GET /services_chargers/1
  # GET /services_chargers/1.xml
  def show
    @services_charger = ServicesCharger.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @services_charger }
    end
  end

  # GET /services_chargers/new
  # GET /services_chargers/new.xml
  def new
    @services_charger = ServicesCharger.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @services_charger }
    end
  end

  # GET /services_chargers/1/edit
  def edit
    @services_charger = ServicesCharger.find(params[:id])
  end

  # POST /services_chargers
  # POST /services_chargers.xml
  def create
    @services_charger = ServicesCharger.new(params[:services_charger])

    respond_to do |format|
      if @services_charger.save
        format.html { redirect_to(@services_charger, :notice => 'ServicesCharger was successfully created.') }
        format.xml  { render :xml => @services_charger, :status => :created, :location => @services_charger }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @services_charger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /services_chargers/1
  # PUT /services_chargers/1.xml
  def update
    @services_charger = ServicesCharger.find(params[:id])

    respond_to do |format|
      if @services_charger.update_attributes(params[:services_charger])
        format.html { redirect_to(@services_charger, :notice => 'ServicesCharger was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @services_charger.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /services_chargers/1
  # DELETE /services_chargers/1.xml
  def destroy
    @services_charger = ServicesCharger.find(params[:id])
    @services_charger.destroy

    respond_to do |format|
      format.html { redirect_to(services_chargers_url) }
      format.xml  { head :ok }
    end
  end
end
