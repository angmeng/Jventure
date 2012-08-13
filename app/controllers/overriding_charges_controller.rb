class OverridingChargesController < ApplicationController
  # GET /overriding_charges
  # GET /overriding_charges.xml
  def index
    @overriding_charges = OverridingCharge.all.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @overriding_charges }
    end
  end

  # GET /overriding_charges/1
  # GET /overriding_charges/1.xml
  def show
    @overriding_charge = OverridingCharge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @overriding_charge }
    end
  end

  # GET /overriding_charges/new
  # GET /overriding_charges/new.xml
  def new
    @overriding_charge = OverridingCharge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @overriding_charge }
    end
  end

  # GET /overriding_charges/1/edit
  def edit
    @overriding_charge = OverridingCharge.find(params[:id])
  end

  # POST /overriding_charges
  # POST /overriding_charges.xml
  def create
    @overriding_charge = OverridingCharge.new(params[:overriding_charge])

    respond_to do |format|
      if @overriding_charge.save
        format.html { redirect_to(@overriding_charge, :notice => 'OverridingCharge was successfully created.') }
        format.xml  { render :xml => @overriding_charge, :status => :created, :location => @overriding_charge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @overriding_charge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /overriding_charges/1
  # PUT /overriding_charges/1.xml
  def update
    @overriding_charge = OverridingCharge.find(params[:id])

    respond_to do |format|
      if @overriding_charge.update_attributes(params[:overriding_charge])
        format.html { redirect_to(@overriding_charge, :notice => 'OverridingCharge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @overriding_charge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /overriding_charges/1
  # DELETE /overriding_charges/1.xml
  def destroy
    @overriding_charge = OverridingCharge.find(params[:id])
    @overriding_charge.destroy

    respond_to do |format|
      format.html { redirect_to(overriding_charges_url) }
      format.xml  { head :ok }
    end
  end
end
