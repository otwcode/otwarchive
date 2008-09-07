class TagRelationshipsController < ApplicationController
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status

  # GET /tag_relationships
  # GET /tag_relationships.xml
  def index
    @tag_relationships = TagRelationshipKind.find(:all, :order => 'distance')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tag_relationships }
    end
  end

  # GET /tag_relationships/1
  # GET /tag_relationships/1.xml
  def show
    @tag_relationship = TagRelationshipKind.find(params[:id])
    @taggings = @tag_relationship.tag_relationships
    @categories = TagCategory.find(:all, :include => 'tags')
    if @tag_relationship == TagRelationshipKind.disambiguation
     render :action => 'ambiguous'
    end
  end

  # GET /tag_relationships/new
  # GET /tag_relationships/new.xml
  def new
    @tag_relationship = TagRelationship.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tag_relationships/1/edit
  def edit
    @tag_relationship = TagRelationshipKind.find(params[:id])
  end

  # POST /tag_relationships
  # POST /tag_relationships.xml
  def create
    @new_tag_relationship = TagRelationship.new(params[:tag_relationship])
    @tag_relationship = TagRelationship.new
    @tag_categories = TagCategory.find(:all, :order => :name)
    @relationships = TagRelationshipKind.find(:all, :order => :name)
    respond_to do |format|
      if @new_tag_relationship.save
        flash[:notice] = 'Tag Relationship was successfully created.'.t
        format.html { redirect_to(@new_tag_relationship) }
        format.js
      else
        format.html { render :action => "new" }
        format.js
      end
    end
  end

  # PUT /tag_relationships/1
  # PUT /tag_relationships/1.xml
  def update
    @tag_relationship = TagRelationshipKind.find(params[:id])

    respond_to do |format|
      if @tag_relationship.update_attributes(params[:tag_relationship])
        flash[:notice] = 'TagRelationship was successfully updated.'.t
        format.html { redirect_to(@tag_relationship) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag_relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_relationships/1
  # DELETE /tag_relationships/1.xml
  def destroy
    @tag_relationship = TagRelationshipKind.find(params[:id])
    @tag_relationship.destroy

    respond_to do |format|
      format.html { redirect_to(tag_relationships_url) }
      format.xml  { head :ok }
    end
  end
  
  def update_tag
    @tag = Tag.find(params[:id])
    @tag_relationship = TagRelationshipKind.find(params[:relationship])
    @taggable = Tag.find(params[:taggable])
    @tagging = TagRelationship.create(:tag => @tag, :related_tag => @taggable, :tag_relationship_kind => @tag_relationship)
  end

end
