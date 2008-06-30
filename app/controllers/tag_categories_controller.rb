class TagCategoriesController < ApplicationController

#permit('wranglers',
# :permission_denied_redirection => {:controller => :works, :action => :index },
# :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.')

  # GET /tag_categories
  # GET /tag_categories.xml
  def index
    @tag_categories = TagCategory.ordered(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tag_categories }
    end
  end

  # GET /tag_categories/1
  # GET /tag_categories/1.xml
  def show
    @tag_category = TagCategory.find(params[:id], :include => 'tags')
    if @tag_category == TagCategory.ambiguous
     render :action => 'ambiguous'
    elsif @tag_category == TagCategory.default
     render :action => 'freeform'
    end
  end

  # GET /tag_categories/new
  # GET /tag_categories/new.xml
  def new
    @tag_category = TagCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag_category }
    end
  end

  # GET /tag_categories/1/edit
  def edit
    @tag_category = TagCategory.find(params[:id])
  end

  # POST /tag_categories
  # POST /tag_categories.xml
  def create
    @tag_category = TagCategory.new(params[:tag_category])

    respond_to do |format|
      if @tag_category.save
        flash[:notice] = 'TagCategory was successfully created.'
        format.html { redirect_to tag_categories_path }
        format.xml  { render :xml => @tag_category, :status => :created, :location => @tag_category }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tag_categories/1
  # PUT /tag_categories/1.xml
  def update
    @tag_category = TagCategory.find(params[:id])

    respond_to do |format|
      if @tag_category.update_attributes(params[:tag_category])
        flash[:notice] = 'TagCategory was successfully updated.'
        format.html { redirect_to tag_categories_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag_category.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_categories/1
  # DELETE /tag_categories/1.xml
  def destroy
    @tag_category = TagCategory.find(params[:id])
    @tag_category.destroy

    respond_to do |format|
      format.html { redirect_to(tag_categories_url) }
      format.xml  { head :ok }
    end
  end

  def update_tag
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
  end
  
  def change_tag
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
  end
   
  def add_relationship
    @tag = Tag.find(params[:id])
    @tag_category = TagCategory.find(params[:category])
    if @tag_category == TagCategory.ambiguous
      @tag_relationship = TagRelationship.disambiguate
      Tagging.create(:tag => @tag, :taggable => Tag.find(params[:taggable]), :tag_relationship => @tag_relationship)
    else
        flash[:error] = 'Unknown Tag Relationship.'       
    end
  end
end
