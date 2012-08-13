class PaymentFeesController < ApplicationController
  before_filter :authenticated_admin
  
  # GET /payment_fees
  # GET /payment_fees.xml
  def index
    @payment_fees = PaymentFee.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payment_fees }
    end
  end

  # GET /payment_fees/1
  # GET /payment_fees/1.xml
  def show
    @payment_fee = PaymentFee.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment_fee }
    end
  end

  # GET /payment_fees/new
  # GET /payment_fees/new.xml
  def new
    @payment_fee = PaymentFee.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment_fee }
    end
  end

  # GET /payment_fees/1/edit
  def edit
    @payment_fee = PaymentFee.find(params[:id])
  end

  # POST /payment_fees
  # POST /payment_fees.xml
  def create
    @payment_fee = PaymentFee.new(params[:payment_fee])

    respond_to do |format|
      if @payment_fee.save
        flash[:notice] = 'PaymentFee was successfully created.'
        format.html { redirect_to(@payment_fee) }
        format.xml  { render :xml => @payment_fee, :status => :created, :location => @payment_fee }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment_fee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payment_fees/1
  # PUT /payment_fees/1.xml
  def update
    @payment_fee = PaymentFee.find(params[:id])

    respond_to do |format|
      if @payment_fee.update_attributes(params[:payment_fee])
        flash[:notice] = 'PaymentFee was successfully updated.'
        format.html { redirect_to(@payment_fee) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payment_fee.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payment_fees/1
  # DELETE /payment_fees/1.xml
  def destroy
    @payment_fee = PaymentFee.find(params[:id])
    @payment_fee.destroy

    respond_to do |format|
      format.html { redirect_to(payment_fees_url) }
      format.xml  { head :ok }
    end
  end
end
