class MiscellaneousItemsController < ApplicationController
  before_filter :authenticated_admin
  # GET /miscellaneous_items
  # GET /miscellaneous_items.xml
  def index
    if params[:from] and params[:to]
        if params[:from].blank? and params[:to].blank?

          flash[:error] = "Please choose a valid date"
          @search = MiscellaneousItem.search(params[:search])
          @miscellaneous_items = [] #@search.all(:order => "transaction_date DESC, amount", :limit => 0, :joins => :agent)

        else
          from = Date.parse(params[:from]).to_s rescue from = Date.today.to_s
          to = Date.parse(params[:to]).to_s rescue to = Date.today.to_s

          @search = MiscellaneousItem.search(params[:search])
          @search.transaction_date_greater_than_or_equal_to(from)
          @search.transaction_date_less_than_or_equal_to(to)

          if params[:option]
            unless params[:option][:agent_name].blank?
              check_name = params[:option][:agent_name]
            end
          end
          if check_name
            agent_id = MiscellaneousItem.check_agent_name(check_name)
            @search.agent_id_equals(agent_id)
            @miscellaneous_items = @search.all
          else
            @miscellaneous_items = @search.all
          end
          
        end
 
    else
      @search = MiscellaneousItem.search(params[:search])
      @miscellaneous_items = [] #@search.all(:order => "date_paid DESC", :limit => 0)
    end
    
    @miscellaneous_items = @miscellaneous_items.paginate(:page => params[:page], :per_page => 30)

  end

  # GET /miscellaneous_items/1
  # GET /miscellaneous_items/1.xml
  def show
    @miscellaneous_item = MiscellaneousItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @miscellaneous_item }
    end
  end
  
  def show_agent
    @agents = Agent.all(:conditions => ['code LIKE ?', "#{params[:search]}%"])
    @agents.each {|c|
      c.code = c.screen_name
    }
  end

  # GET /miscellaneous_items/new
  # GET /miscellaneous_items/new.xml
  def new
    @miscellaneous_item = MiscellaneousItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @miscellaneous_item }
    end
  end

  # GET /miscellaneous_items/1/edit
  def edit
    @miscellaneous_item = MiscellaneousItem.find(params[:id])
  end

  # POST /miscellaneous_items
  # POST /miscellaneous_items.xml
  def create
    @miscellaneous_item = MiscellaneousItem.new(params[:miscellaneous_item])

    respond_to do |format|
      if @miscellaneous_item.save
        flash[:notice] = 'MiscellaneousItem was successfully created.'
        format.html { redirect_to(@miscellaneous_item) }
        format.xml  { render :xml => @miscellaneous_item, :status => :created, :location => @miscellaneous_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @miscellaneous_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /miscellaneous_items/1
  # PUT /miscellaneous_items/1.xml
  def update
    @miscellaneous_item = MiscellaneousItem.find(params[:id])

    respond_to do |format|
      if @miscellaneous_item.update_attributes(params[:miscellaneous_item])
        flash[:notice] = 'MiscellaneousItem was successfully updated.'
        format.html { redirect_to(@miscellaneous_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @miscellaneous_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /miscellaneous_items/1
  # DELETE /miscellaneous_items/1.xml
  def destroy
    @miscellaneous_item = MiscellaneousItem.find(params[:id])
    @miscellaneous_item.destroy

    respond_to do |format|
      format.html { redirect_to(miscellaneous_items_url) }
      format.xml  { head :ok }
    end
  end

  def remove_items
    params[:item] ||= []
    params[:item].each do |item_id, content|
      found = MiscellaneousItem.find(item_id.to_i) if content[:selected].to_i == 1
      found.destroy
    end
    flash[:notice] = "Items selected has been destroyed"
    redirect_to :action => "index"
  end
end
