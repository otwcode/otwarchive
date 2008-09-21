class TagWranglingsController < ApplicationController   
  
  permit "tag_wrangler", :permission_denied_message => "Sorry, the page you tried to access is for authorized tag wranglers only.".t
  before_filter :check_user_status
  
  def index
    if params[:category1] && params[:category2]
      @category1 = TagCategory.find_by_name(params[:category1])
      @category2 = TagCategory.find_by_name(params[:category2]) 
    end
    if @category1 && @category2
      if @category2.name =~ /Character/
        currently_tagged = []
      else
        existing_relationships = TagRelationship.tagged_by_category(@category1, @category2)
        currently_tagged = existing_relationships.blank? ? [] : existing_relationships.collect(&:tag)
      end
      @potential_tags = @category1.tags.valid.find(:all, :order => :name) - currently_tagged
      @potential_related_tags = @category2.tags.valid.find(:all, :order => :name)
      @tag_relationship_kind = TagRelationshipKind.find_by_name('child')
    else
      @current_tag_relationships = TagRelationship.all
      @tag_relationship = TagRelationship.new
      @tag_categories = TagCategory.find(:all, :order => :name)
      @relationships = TagRelationshipKind.find(:all, :order => :name)  
    end
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
