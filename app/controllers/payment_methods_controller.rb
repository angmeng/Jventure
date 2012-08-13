class PaymentMethodsController < ApplicationController
  before_filter :authenticated_admin

  def index
    @payment_methods = PaymentMethod.all
  end
  
  def show
    @payment_method = PaymentMethod.find(params[:id])
  end
  
  def new
    @payment_method = PaymentMethod.new
  end
  
  def create
    @payment_method = PaymentMethod.new(params[:payment_method])
    if @payment_method.save
      flash[:notice] = "Successfully created payment method."
      redirect_to @payment_method
    else
      render :action => 'new'
    end
  end
  
  def edit
    @payment_method = PaymentMethod.find(params[:id])
  end
  
  def update
    @payment_method = PaymentMethod.find(params[:id])
    if @payment_method.update_attributes(params[:payment_method])
      flash[:notice] = "Successfully updated payment method."
      redirect_to @payment_method
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @payment_method = PaymentMethod.find(params[:id])
    checked, msg = @payment_method.verify_destroy
    if checked
      flash[:notice] = msg
    else
      flash[:error] = msg
    end
   
    redirect_to payment_methods_url
  end
end
