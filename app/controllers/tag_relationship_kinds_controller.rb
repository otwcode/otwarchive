class TagRelationshipKindsController < ApplicationController 
	def index
		@tag_relationship_kinds = TagRelationshipKind.find(:all, :order => :name)
	end
	
	def show
		@tag_relationship_kind = TagRelationshipKind.find(params[:id])
		@current_relationships = @tag_relationship_kind.tag_relationships.find(:all, :include => :tag, :order => 'tags.name')
	end
  
  # GET /tag_relationship_kinds/new
  def new
    @tag_relationship_kind = TagRelationshipKind.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # POST /tag_relationship_kinds
  def create
    @tag_relationship_kind = TagRelationshipKind.new(params[:tag_relationship_kind])
    respond_to do |format|
      if @tag_relationship_kind.save
        flash[:notice] = 'Tag Relationship Kind was successfully created.'.t
        format.html { redirect_to tag_wranglings_path }
        format.js
      else
        format.html { render :action => "new" }
        format.js
      end
    end
	end
		
	def edit
		@tag_relationship_kind = TagRelationshipKind.find(params[:id])
	end
		
  # PUT /tag_relationship_kinds/1
  def update
    @tag_relationship_kind = TagRelationshipKind.find(params[:id])   
		respond_to do |format|
			if @tag_relationship_kind.update_attributes(params[:tag_relationship_kind])
				flash[:notice] = 'Tag Relationship Kind was successfully updated.'.t
				format.html { redirect_to(@tag_relationship_kind) }
			else
				format.html { render :action => "edit" }
			end
		end
  end 
end
