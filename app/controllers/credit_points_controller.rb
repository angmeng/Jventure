class CreditPointsController < ApplicationController
  before_filter :authenticated_admin_and_agent
  # GET /credits
  # GET /credits.xml
  def index
    if is_admin?
      @credits = CreditPoint.all(:include => [:agent], :order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    elsif is_agent?
      @credits = CreditPoint.all(:conditions => ["agent_id = ?", current_id], :include => [:agent], :order => "created_at DESC").paginate(:page => params[:page], :per_page => 30)
    end
  

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @credits }
    end
  end

  # GET /credits/1
  # GET /credits/1.xml
  def show
    @credit = CreditPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @credit }
    end
  end

  # GET /credits/new
  # GET /credits/new.xml
  def new
    if is_admin?
    @credit = CreditPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @credit }
    end
    end
  end

  # GET /credits/1/edit
  def edit
    @credit = CreditPoint.find(params[:id])
  end

  # POST /credits
  # POST /credits.xml
  def create
    @credit = CreditPoint.new(params[:credit_point])

    respond_to do |format|
      if @credit.save
        flash[:notice] = 'CreditPoint was successfully created.'
        format.html { redirect_to(@credit) }
        format.xml  { render :xml => @credit, :status => :created, :location => @credit }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /credits/1
  # PUT /credits/1.xml
  def update
    @credit = CreditPoint.find(params[:id])

    respond_to do |format|
      if @credit.update_attributes(params[:credit])
        flash[:notice] = 'CreditPoint was successfully updated.'
        format.html { redirect_to(@credit) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @credit.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /credits/1
  # DELETE /credits/1.xml
  def destroy
    @credit = CreditPoint.find(params[:id])
    @credit.destroy

    respond_to do |format|
      format.html { redirect_to(credits_url) }
      format.xml  { head :ok }
    end
  end
end
