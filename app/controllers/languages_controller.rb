class LanguagesController < ApplicationController
  before_filter :check_permission, :only => :new

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end  
  
  def set
    if params[:language_id]
      session[:locale] = params[:language_id]     
    end
    redirect_to :back rescue redirect_to '/'
  end
  
  def index
    @languages = Language.all(:order => :iso)
  end
    
  def show
    @language = Language.find_by_short(params[:id])
    @works = @language.works.visible.ordered('revised_at', 'DESC').limited(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
  end
  
  def new
    @language = Language.new
  end
  
  def create   
    @language = Language.new(params[:language])
    if @language.save
      flash[:notice] = t('notices.languages.successfully_added', :default => 'Language was successfully added.')
      redirect_to languages_path
    else
      render :action => "new"
    end      
  end 
end