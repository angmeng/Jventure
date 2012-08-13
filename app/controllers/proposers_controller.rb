class ProposersController < ApplicationController
  before_filter :authenticated_admin_and_agent

  def index
    @proposers = Proposer.all
  end
  
  def show
    @proposer = Proposer.find(params[:id])
  end
  
  def new
    @proposer = Proposer.new
  end
  
  def create
    @proposer = Proposer.new(params[:proposer])
    if @proposer.save
      flash[:notice] = "Successfully created proposer."
      redirect_to @proposer
    else
      render :action => 'new'
    end
  end
  
  def edit
    @proposer = Proposer.find(params[:id])
  end
  
  def update
    @proposer = Proposer.find(params[:id])
    if @proposer.update_attributes(params[:proposer])
      flash[:notice] = "Successfully updated proposer."
      redirect_to @proposer
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @proposer = Proposer.find(params[:id])
    @proposer.destroy
    flash[:notice] = "Successfully destroyed proposer."
    redirect_to proposers_url
  end
end
