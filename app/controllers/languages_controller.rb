class LanguagesController < ApplicationController
  before_filter :check_permission, :only => [:new, :create]

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end  
  
  def index
    @languages = Language.default_order
  end
    
  def show
    @language = Language.find_by_short(params[:id])
    @works = @language.works.recent.visible.limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
  end
  
  def new
    @language = Language.new
  end
  
  def create   
    @language = Language.new(params[:language])
    if @language.save
      flash[:notice] = t('successfully_added', :default => 'Language was successfully added.')
      redirect_to languages_path
    else
      render :action => "new"
    end      
  end 
end