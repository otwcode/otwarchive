class TaggingsController < ApplicationController

#  permit('wranglers',
#          :permission_denied_redirection => {:controller => :works, :action => :index },
#          :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.',
#          :except => [ :show, :index ])
  
  # GET /taggings
  # GET /taggings.xml
  def index
    # only interested in tag to tag taggings
    @taggings = Tagging.find(:all, :conditions => {:taggable_type => 'Tag'})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @taggings }
    end
  end

  # GET /taggings/1
  # GET /taggings/1.xml
  def show
    @tagging = Tagging.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tagging }
    end
  end

  # GET /taggings/new
  # GET /taggings/new.xml
  def new
    @tagging = Tagging.new
    @tags = Tag.find(:all, :order => 'name')

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tagging }
    end
  end

  # GET /taggings/1/edit
  def edit
    @tagging = Tagging.find(params[:id])
  end

  # POST /taggings
  # POST /taggings.xml
  def create
    @tagging = Tagging.new(params[:tagging])
    @tagging.taggable_type = 'Tag'

    respond_to do |format|
      if @tagging.save
        flash[:notice] = 'Tagging was successfully created.'
        format.html { redirect_to(@tagging) }
        format.xml  { render :xml => @tagging, :status => :created, :location => @tagging }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tagging.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /taggings/1
  # PUT /taggings/1.xml
  def update
    @tagging = Tagging.find(params[:id])

    respond_to do |format|
      if @tagging.update_attributes(params[:tagging])
        flash[:notice] = 'Tagging was successfully updated.'
        format.html { redirect_to(@tagging) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tagging.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /taggings/1
  # DELETE /taggings/1.xml
  def destroy
    @tagging = Tagging.find(params[:id])
    @tagging.destroy

    respond_to do |format|
      format.html { redirect_to(taggings_url) }
      format.xml  { head :ok }
    end
  end
end
