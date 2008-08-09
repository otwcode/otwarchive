class FandomsController < ApplicationController
  
  def index
    fandom_category = TagCategory.find_or_create_by_name("Fandom")
    @fandoms = fandom_category.tags.find(:all, :order => :name).paginate(:page => params[:page])
  end
  
  def show
    @fandom = Tag.find(params[:id])
    @works = @fandom.works.visible(current_user, :order => "works.created_at DESC").paginate(:page => params[:page])
  end
    
end
