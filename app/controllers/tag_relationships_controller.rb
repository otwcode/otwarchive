class TagRelationshipsController < ApplicationController

#permit('wranglers',
# :permission_denied_redirection => {:controller => :works, :action => :index },
# :permission_denied_message => 'Sorry, the page you have requested is for tag wranglers only! Please contact an admin if you think you should have access.')

  # GET /tag_relationships
  # GET /tag_relationships.xml
  def index
    @tag_relationships = TagRelationship.find(:all, :order => 'distance')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tag_relationships }
    end
  end

  # GET /tag_relationships/1
  # GET /tag_relationships/1.xml
  def show
    @tag_relationship = TagRelationship.find(params[:id])
    @taggings = @tag_relationship.taggings.select{|tagging| tagging.taggable_type == 'Tag'}
    @categories = TagCategory.official(:include => 'tags')
    if @tag_relationship == TagRelationship.disambiguate
     render :action => 'ambiguous'
    end
  end

  # GET /tag_relationships/new
  # GET /tag_relationships/new.xml
  def new
    @tag_relationship = TagRelationship.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag_relationship }
    end
  end

  # GET /tag_relationships/1/edit
  def edit
    @tag_relationship = TagRelationship.find(params[:id])
  end

  # POST /tag_relationships
  # POST /tag_relationships.xml
  def create
    @tag_relationship = TagRelationship.new(params[:tag_relationship])

    respond_to do |format|
      if @tag_relationship.save
        flash[:notice] = 'TagRelationship was successfully created.'
        format.html { redirect_to(@tag_relationship) }
        format.xml  { render :xml => @tag_relationship, :status => :created, :location => @tag_relationship }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag_relationship.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tag_relationships/1
  # PUT /tag_relationships/1.xml
  def update
    @tag_relationship = TagRelationship.find(params[:id])

    respond_to do |format|
      if @tag_relationship.update_attributes(params[:tag_relationship])
        flash[:notice] = 'TagRelationship was successfully updated.'
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
    @tag_relationship = TagRelationship.find(params[:id])
    @tag_relationship.destroy

    respond_to do |format|
      format.html { redirect_to(tag_relationships_url) }
      format.xml  { head :ok }
    end
  end
  
  def update_tag
    @tag = Tag.find(params[:id])
    @tag_relationship = TagRelationship.find(params[:relationship])
    @taggable = Tag.find(params[:taggable])
    @tagging = Tagging.create(:tag => @tag, :taggable => @taggable, :tag_relationship => @tag_relationship)
  end

end
