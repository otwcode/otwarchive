class TagsController < ApplicationController

#  permit 'wranglers',
#          :permission_denied_redirection => {:controller => :works, :action => :index },
#          :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.',
#          :except => [ :show, :index ]
  
  # GET /tags
  # GET /tags.xml
  def index
    @tags = Tag.find(:all, :order => 'tag_category_id')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])
    @works = @tag.tagees('Works')
    @bookmarks = @tag.tagees('Bookmarks')

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
    if @tag.tag_category
      @categories = [ @tag.tag_category, TagCategory.ambiguous, TagCategory.default ].uniq
    else # should never be nil, but just in case
      @categories = TagCategory.find(:all, :order => 'name')
    end
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

end
