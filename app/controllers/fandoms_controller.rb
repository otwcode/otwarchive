class FandomsController < ApplicationController
  
  def index
    fandom_category = TagCategory.find_or_create_by_name("Fandom")
    @fandoms = fandom_category.tags.find(:all, :order => :name).paginate(:page => params[:page])
  end
  
  def show
    @fandom = Tag.find(params[:id])
    #@works = is_admin? ? @fandom.works.find(:all, :order => "works.created_at DESC").paginate(:page => params[:page]) : 
    #                     @fandom.works.visible(current_user, :order => "works.created_at DESC").paginate(:page => params[:page])
    #@tag_categories = TagCategory.official
    redirect_to fandom_works_path(@fandom)
  end
    
end
