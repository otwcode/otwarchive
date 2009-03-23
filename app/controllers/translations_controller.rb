class TranslationsController < ApplicationController

  permit "translator", :permission_denied_message => "Sorry, the page you tried to access is for authorized translators only."
  # this is copied from a demo app, and will be seriously overhauled!

  before_filter :find_locale
  protect_from_forgery :only => []

  # in_place_edit_for :translation, :text
  
  def find_locale
    @locale = @current_locale #Locale.find(params[:locale_id])
    ## Of course, you can authorize users to edit the translations as you wish, for example:
    # raise "No access" unless @current_member.locales.find(:all).include? @locale
    if @locale.main?
      @main_locale = @locale
    else
      @main_locale = Locale.find_main_cached
    end
  end
  
  def index    
    @groups = @main_locale.translations.find(:all, :order => "namespace, id").group_by(&:namespace)
  end
  
  def browse
    @namespaces = Translation.find(:all, :select => 'DISTINCT namespace', :order => :namespace).collect(&:namespace)
  end
  
  def update_in_place
    @field_name = params[:editorId]
    main_translation = @main_locale.translations.find params[:id]
    @translation = main_translation.counterpart_in(@locale)
    @translation.text = params[:value]
    if @translation.text && @translation.save
      if session[:unsaved]
        session[:unsaved][@field_name] = nil
      end
      # render :text => translation.text.blank? ? '<span class="inplaceeditor-empty">click to edit…</span>' : ERB::Util.h(translation.text)
    else
      # since the save failed, we need to store the unsaved field 
      # data into our session variable - notice we are using
      # a hash within the session - just in case they start to 
      # edit two different fields at once without saving, this 
      # hash will keep track of what data goes with what field
      session[:unsaved] ||= {}
      session[:unsaved][@field_name] = params[:value]
    end
    # falls through to RJS template
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
        format.html { redirect_to(admin_translations_url) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @translation = Translation.find(params[:id])

    respond_to do |format|
      if @translation.update_attributes(params[:translation])
        flash[:notice] = 'Translation was successfully updated.'
        format.html { redirect_to(admin_translation_url(@translation)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy

    respond_to do |format|
      format.html { redirect_to(admin_translations_url) }
    end
  end
end
