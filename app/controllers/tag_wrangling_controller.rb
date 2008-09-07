class TagWranglingController < ApplicationController
  
  def index
    @current_tag_relationships = TagRelationship.all
    @tag_relationship = TagRelationship.new
    @tag_categories = TagCategory.find(:all, :order => :name)
    @relationships = TagRelationshipKind.find(:all, :order => :name)
  end
  
  def dynamic_relationships
    @tags = TagCategory.find(params[:tag1]).tags if params[:tag1]
    @relationship = TagRelationshipKind.find(params[:relationship]) if params[:relationship] 
    @related_tags = TagCategory.find(params[:tag2]).tags if params[:tag2]
    respond_to do |format| 
      format.js
    end
  end
end
