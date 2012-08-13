class ProposedPeopleController < ApplicationController
  before_filter :authenticated_admin_and_agent

  # GET /proposed_people
  # GET /proposed_people.xml
  def index
    @proposed_people = ProposedPerson.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @proposed_people }
    end
  end

  # GET /proposed_people/1
  # GET /proposed_people/1.xml
  def show
    @proposed_person = ProposedPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @proposed_person }
    end
  end

  # GET /proposed_people/new
  # GET /proposed_people/new.xml
  def new
    @proposed_person = ProposedPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @proposed_person }
    end
  end

  # GET /proposed_people/1/edit
  def edit
    @proposed_person = ProposedPerson.find(params[:id])
  end

  # POST /proposed_people
  # POST /proposed_people.xml
  def create
    @proposed_person = ProposedPerson.new(params[:proposed_person])

    respond_to do |format|
      if @proposed_person.save
        flash[:notice] = 'ProposedPerson was successfully created.'
        format.html { redirect_to(@proposed_person) }
        format.xml  { render :xml => @proposed_person, :status => :created, :location => @proposed_person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @proposed_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /proposed_people/1
  # PUT /proposed_people/1.xml
  def update
    @proposed_person = ProposedPerson.find(params[:id])

    respond_to do |format|
      if @proposed_person.update_attributes(params[:proposed_person])
        flash[:notice] = 'ProposedPerson was successfully updated.'
        format.html { redirect_to(@proposed_person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @proposed_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /proposed_people/1
  # DELETE /proposed_people/1.xml
  def destroy
    @proposed_person = ProposedPerson.find(params[:id])
    @proposed_person.destroy

    respond_to do |format|
      format.html { redirect_to(proposed_people_url) }
      format.xml  { head :ok }
    end
  end
end
