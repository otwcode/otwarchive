class TagWranglingsController < ApplicationController   
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status
  
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
