class TagWranglingsController < ApplicationController   
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status
  
  def index
    @category1 = TagCategory.find_by_name(params[:category1])
    @category2 = TagCategory.find_by_name(params[:category2])
    # TODO fancier relationships than just child
    @tag_relationship_kind = TagRelationshipKind.child
    if @category1 && @category2
      current_relationships = TagRelationship.tagged_by_category(@category1, @category2)
      currently_tagged = current_relationships.blank? ? [] : current_relationships.collect(&:tag)
      @potential_tags = @category1.tags.valid.find(:all, :order => :name) - currently_tagged
      @potential_related_tags = @category2.tags.canonical.valid.find(:all, :order => :name)
    end
    @tag = Tag.find(params[:tag]) if params[:tag]
    respond_to do |format|
      format.html 
      format.js
    end
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
