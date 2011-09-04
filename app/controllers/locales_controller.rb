class LocalesController < ApplicationController
  before_filter :check_permission, :only => [:new, :create]

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end  
  
  def set
    if params[:locale_id]
      session[:locale] = params[:locale_id]     
    end
    # Temporary message for non-default locales for launch of open beta
    unless params[:locale_id] == ArchiveConfig.DEFAULT_LOCALE_ISO
      flash[:notice] = "We're working on making the <a href='http://archiveofourown.org/archive_faqs#locales'>AO3 
      available in your language</a>, too! \\o/ If you want to help us add more languages, 
      <a href='http://transformativeworks.org/node/540'>please consider volunteering</a>."
    end
    redirect_to(request.env["HTTP_REFERER"] || root_path)
  end
  
  def index
    @locales = Locale.all(:order => :iso)
  end
    
  def show
    @locale = Locale.find_by_iso(params[:id])
  end
  
  def new
    @locale = Locale.new
    @languages = Language.default_order
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