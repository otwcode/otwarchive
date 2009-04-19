class TranslationsController < ApplicationController

  permit "translator", :permission_denied_message => "Sorry, the page you tried to access is for authorized translators only."
  before_filter :find_locale
  
  def find_locale
    @locale = params[:locale_id] ? Locale.find_by_iso(params[:locale_id]) : @current_locale
    if @locale.main?
      @main_locale = @locale
    else
      @main_locale = Locale.find_main_cached
    end
  end
  
  def index
    if params[:namespace]
      @current_namespace = params[:namespace]
      @translations = @main_locale.translations.find(:all, :order => "namespace, id", :conditions => {:namespace => params[:namespace]}).paginate(:page => params[:page])
    else  
      @translations = @main_locale.translations.find(:all, :order => "namespace, id").paginate(:page => params[:page])
    end
    @translators = @locale.has_translators
    @namespaces = Translation.find(:all, :select => 'DISTINCT namespace', :order => :namespace).collect(&:namespace)   
  end

  def show
    @translation = Translation.find(params[:id])
  end

  def new
    @translation = Translation.new
  end

  def edit
    @translation = Translation.find(params[:id])
  end

  def create
    @translation = Translation.new(params[:translation])

    respond_to do |format|
      if @translation.save
        flash[:notice] = 'Translation was successfully created.'
        format.html { redirect_to :back }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @translation = Translation.find(params[:id])
    @locale = Locale.find(@translation.locale_id)
    @main_translation = @translation.counterpart_in_main
    @translators = @locale.has_translators
    # TODO: move to model
    if current_user.id == @translation.beta_id && !@translation.text.blank?
      params[:translation][:betaed] = true
    end

    respond_to do |format|
      if @translation.update_attributes(params[:translation])
        flash[:notice] = 'Translation was successfully updated.'
        format.html { redirect_to :back }
        format.js
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy

    respond_to do |format|
      format.html { redirect_to translations_path }
    end
  end
end
