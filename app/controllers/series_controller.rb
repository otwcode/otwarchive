class SeriesController < ApplicationController 
  before_filter :is_author, :only => [ :edit, :update, :destroy ]
  before_filter :check_user_status, :only => [:new, :create, :edit, :update]
  before_filter :check_permission_to_view, :only => [:show]
  
  # Only authors of the series should be able to edit it
  def is_author
    @series = Series.find(params[:id])
    unless current_user.is_a?(User) && current_user.is_author_of?(@series)
      flash[:error] = "Sorry, but you don't have permission to make edits.".t
      redirect_to(@series)     
    end
  end
  
  # Hidden series should only be visible to admins and authors
  def check_permission_to_view
    @series = Series.find(params[:id])
    can_view_hidden = is_admin? || (current_user.is_a?(User) && current_user.is_author_of?(@series))
	  access_denied if (@series.hidden_by_admin? && !can_view_hidden)
  end
  
  # GET /series
  # GET /series.xml
  def index
    if params[:user_id]
      @user = User.find_by_login(params[:user_id])
      @series = @user.series
    else
      @series = Series.all
    end

  end

  # GET /series/1
  # GET /series/1.xml
  def show
    @series = Series.find(params[:id])
  end

  # GET /series/new
  # GET /series/new.xml
  def new
    @series = Series.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @series }
    end
  end

  # GET /series/1/edit
  def edit
    @series = Series.find(params[:id])
  end

  # POST /series
  # POST /series.xml
  def create
    @series = Series.new(params[:series])

    respond_to do |format|
      if @series.save
        flash[:notice] = 'Series was successfully created.'.t
        format.html { redirect_to(@series) }
        format.xml  { render :xml => @series, :status => :created, :location => @series }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /series/1
  # PUT /series/1.xml
  def update
    @series = Series.find(params[:id])

    respond_to do |format|
      if @series.update_attributes(params[:series])
        flash[:notice] = 'Series was successfully updated.'.t
        format.html { redirect_to(@series) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @series.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /series/1
  # DELETE /series/1.xml
  def destroy
    @series = Series.find(params[:id])
    @series.destroy

    respond_to do |format|
      format.html { redirect_to(current_user) }
      format.xml  { head :ok }
    end
  end
end
