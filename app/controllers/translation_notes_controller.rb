class TranslationNotesController < ApplicationController
  before_filter :find_locale
  before_filter :check_permission

  def check_permission
    logged_in_as_admin? || permit?("translation_admin") || permit?("translator") || access_denied
  end
  
  def find_locale
    @locale = params[:locale_id] ? Locale.find_by_iso(params[:locale_id]) : @current_locale
  end 
  
  # GET /translation_notes
  # GET /translation_notes.xml
  def index
    if params[:namespace]
      @namespace = params[:namespace]
      @translation_notes = @locale.translation_notes.find_all_by_namespace(params[:namespace])
    else
      @translation_notes = @locale.translation_notes.all
    end
  end

  # GET /translation_notes/1
  # GET /translation_notes/1.xml
  def show
    @translation_note = TranslationNote.find(params[:id])
  end

  # GET /translation_notes/new
  # GET /translation_notes/new.xml
  def new
    @current_namespace = params[:namespace]
    @namespaces = Translation.select('DISTINCT namespace').order(:namespace).collect(&:namespace)
    @translation_note = TranslationNote.new
  end

  # GET /translation_notes/1/edit
  def edit
    @translation_note = TranslationNote.find(params[:id])
  end

  # POST /translation_notes
  # POST /translation_notes.xml
  def create
    @translation_note = TranslationNote.new(params[:translation_note])
    @translation_note.user = current_user
    @translation_note.locale = @locale
    if @translation_note.save
      flash[:notice] = 'Translation note was successfully created.'
      redirect_to translation_notes_path(:namespace => @translation_note.namespace)
    else
      render :action => "new"
    end
  end

  # PUT /translation_notes/1
  # PUT /translation_notes/1.xml
  def update
    @translation_note = TranslationNote.find(params[:id])
    if @translation_note.update_attributes(params[:translation_note])
      flash[:notice] = 'Translation note was successfully updated.'
      redirect_to(@translation_note)
    else
      render :action => "edit"
    end
  end

  # DELETE /translation_notes/1
  # DELETE /translation_notes/1.xml
  def destroy
    @translation_note = TranslationNote.find(params[:id])
    @translation_note.destroy
    redirect_to(translation_notes_url)
  end
end
