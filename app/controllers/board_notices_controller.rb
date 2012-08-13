class BoardNoticesController < ApplicationController
  before_filter :authenticated_admin

  uses_tiny_mce :only => [:new, :create, :edit, :update],
                :options => {
                        :theme => 'advanced',
                        :theme_advanced_resizing => true,
                        :theme_advanced_resize_horizontal => false,
                        :plugins => %w{ table fullscreen safari spellchecker pagebreak style layer save advhr advimage advlink emotions iespell inlinepopups insertdatetime preview media searchreplace print contextmenu paste directionality noneditable visualchars nonbreaking xhtmlxtras template },

               :theme_advanced_buttons1 => %w{ save newdocument | bold italic underline strikethrough | justifyleft justifycenter justifyright justifyfull | styleselect formatselect fontselect fontsizeselect },
               :theme_advanced_buttons2 => %w{ cut copy paste pastetext pasteword | search replace | bullist numlist | outdent indent blockquote | undo redo | link unlink anchor image cleanup help code | insertdate inserttime preview | forecolor backcolor },
               :theme_advanced_buttons3 => %w{ tablecontrols | hr removeformat visualaid | sub sup | charmap emotions iespell media advhr | print | ltr rtl | fullscreen },
               :theme_advanced_buttons4 => %w{ insertlayer moveforward movebackward absolute | styleprops spellchecker | cite abbr acronym del ins attribs | visualchars nonbreaking template blockquote pagebreak | insertfile insertimage },
               :theme_advanced_toolbar_location => "top",
               :theme_advanced_toolbar_align => "left",
               :theme_advanced_statusbar_location => "bottom"
                 }

  # GET /board_notices
  # GET /board_notices.xml
  def index
    @board_notices = BoardNotice.all(:order => 'created_at DESC').paginate(:page => params[:page], :per_page => 30)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @board_notices }
    end
  end

  # GET /board_notices/1
  # GET /board_notices/1.xml
  def show
    @board_notice = BoardNotice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @board_notice }
    end
  end

  # GET /board_notices/new
  # GET /board_notices/new.xml
  def new
    @board_notice = BoardNotice.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @board_notice }
    end
  end

  # GET /board_notices/1/edit
  def edit
    @board_notice = BoardNotice.find(params[:id])
  end

  # POST /board_notices
  # POST /board_notices.xml
  def create
    @board_notice = BoardNotice.new(params[:board_notice])

    respond_to do |format|
      if @board_notice.save
        flash[:notice] = 'BoardNotice was successfully created.'
        format.html { redirect_to(@board_notice) }
        format.xml  { render :xml => @board_notice, :status => :created, :location => @board_notice }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @board_notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /board_notices/1
  # PUT /board_notices/1.xml
  def update
    @board_notice = BoardNotice.find(params[:id])

    respond_to do |format|
      if @board_notice.update_attributes(params[:board_notice])
        flash[:notice] = 'BoardNotice was successfully updated.'
        format.html { redirect_to(@board_notice) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @board_notice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /board_notices/1
  # DELETE /board_notices/1.xml
  def destroy
    @board_notice = BoardNotice.find(params[:id])
    @board_notice.destroy

    respond_to do |format|
      format.html { redirect_to(board_notices_url) }
      format.xml  { head :ok }
    end
  end
end
