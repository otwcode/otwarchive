class LocalesController < ApplicationController
  before_filter :check_permission, :only => [:new, :create, :update, :edit]

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || access_denied
  end
  
  def set
    if params[:locale_id]
      session[:locale] = params[:locale_id]     
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

  # GET /locales/en/edit
  def edit
    @locale = Locale.find_by_iso(params[:id])
    @languages = Language.default_order
  end

  def update
    @locale = Locale.find_by_iso(params[:id])
    @locale.attributes = params[:locale]
    if @locale.save
      flash[:notice] = ts('Your locale was successfully updated.')
    else
      flash[:error] = ts('Sorry, something went wrong. Please try that again.')
    end
    redirect_to action: 'index', status: 303
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
