class TagRelationshipKindsController < ApplicationController 
  
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
  
  
end
