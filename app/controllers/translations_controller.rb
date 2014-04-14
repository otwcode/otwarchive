class TranslationsController < ApplicationController
  before_filter :check_permission

  def check_permission
    logged_in_as_admin? || permit?('translator') || permit?("translation_admin") || access_denied
  end  

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
    conditions = {}
    locale = @main_locale
    if params[:translator_id]
      locale = @locale
      @translator = User.find_by_login(params[:translator_id])
      @path_for_filtering = translator_translations_path(@translator)
      if params[:show] == 'beta'
        conditions[:beta_id] = @translator.id
      else
        conditions[:translator_id] = @translator.id
      end
    end
    if !params[:namespace].blank?
      @current_namespace = params[:namespace]
      conditions[:namespace] = params[:namespace]
    end
    if !params[:status].blank?
      locale = @locale
      @current_status = params[:status]
      if params[:status] == 'Not Translated'
        conditions[:text] = nil
      elsif params[:status] == 'Updated'
        conditions[:updated] = true
      elsif params[:status] == 'Betaed'
        conditions[:betaed] = true
      elsif params[:status] == 'Translated'
        conditions[:translated] = true
        conditions[:betaed] = false
      end      
    end
    @translations = locale.translations.order("namespace, id").where(conditions).paginate(:page => params[:page])
    @translators = @locale.has_translators
    @namespaces = [''] + Translation.select('DISTINCT namespace').order(:namespace).collect(&:namespace)
    @status_list = ['', 'Not Translated', 'Translated', 'Betaed', 'Updated']
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
        format.html { redirect_to(request.env["HTTP_REFERER"] || root_path) }
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
        format.html { redirect_to(request.env["HTTP_REFERER"] || root_path) }
        format.js
      else
        format.html { render :action => "edit" }
        format.js
      end
    end
  end
  
  def assign
    if params[:translator] && !params[:translator][:id].blank?
      to_update = 'translator_id = ' + params[:translator][:id]
    elsif params[:beta] && !params[:beta][:id].blank?
      to_update = 'beta_id = ' + params[:beta][:id]
    end
    if @locale.translations.update_all(to_update, ['namespace = ?', params[:namespace]])
      flash[:notice] = "Translations were assigned"
    else
      flash[:error] = "Translations could not be assigned. Please try again."
    end
    redirect_to translations_path
  end

  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy

    respond_to do |format|
      format.html { redirect_to translations_path }
    end
  end
end
