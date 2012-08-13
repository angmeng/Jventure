class ModeOfPaymentsController < ApplicationController
  before_filter :authenticated_admin

  def index
    @mode_of_payments = ModeOfPayment.all
  end
  
  def show
    @mode_of_payment = ModeOfPayment.find(params[:id])
    @first, @last, @next, @previous =  ModeOfPayment.next_previous_label(@mode_of_payment.id)
  end
  
  def new
    @mode_of_payment = ModeOfPayment.new
  end
  
  def create
    @mode_of_payment = ModeOfPayment.new(params[:mode_of_payment])
    if @mode_of_payment.save
      flash[:notice] = "Successfully created mode of payment."
      redirect_to @mode_of_payment
    else
      render :action => 'new'
    end
  end
  
  def edit
    @mode_of_payment = ModeOfPayment.find(params[:id])
  end
  
  def update
    @mode_of_payment = ModeOfPayment.find(params[:id])
    if @mode_of_payment.update_attributes(params[:mode_of_payment])
      flash[:notice] = "Successfully updated mode of payment."
      redirect_to @mode_of_payment
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @mode_of_payment = ModeOfPayment.find(params[:id])
    checked, msg = @mode_of_payment.verify_destroy
    if checked
      flash[:notice] = msg
    else
      flash[:error] = msg
    end
   
    redirect_to mode_of_payments_url
  end
end
