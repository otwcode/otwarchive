class LocalesController < ApplicationController
  before_filter :check_permission, :only => [:new, :create]

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end  
  
  def set
    if params[:locale_id]
      session[:locale] = params[:locale_id]     
    end
    redirect_to :back rescue redirect_to '/'
  end
  
  def index
    @locales = Locale.all(:order => :iso)
  end
    
  def show
    @locale = Locale.find_by_iso(params[:id])
  end
  
  def new
    @locale = Locale.new
    @languages = Language.all(:order => :short)
  end
  
  def create   
    @locale = Locale.new(params[:locale])
    if @locale.save
      flash[:notice] = t('successfully_added', :default => 'Locale was successfully added.')
      redirect_to locales_path
    else
      render :action => "new"
    end      
  end 
end