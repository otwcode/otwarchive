class LanguagesController < ApplicationController

  def index
    @languages = Language.default_order
  end

  def show
    @language = Language.find_by(short: params[:id])
    @works = @language.works.recent.visible.limit(ArchiveConfig.NUMBER_OF_ITEMS_VISIBLE_IN_DASHBOARD)
  end

  def new
    authorize Language

    @language = Language.new
  end

  def create
    authorize Language

    @language = Language.new(language_params)
    if @language.save
      flash[:notice] = t('successfully_added', default: 'Language was successfully added.')
      redirect_to languages_path
    else
      render action: "new"
    end
  end

  def edit
    authorize Language

    @language = Language.find_by(short: params[:id])
  end

  def update
    authorize Language
    
    @language = Language.find_by(short: params[:id])
    if @language.update(language_params)
      flash[:notice] = t('successfully_updated', default: 'Language was successfully updated.')
      redirect_to @language
    else
      render action: "new"
    end
  end

  private
  def language_params
    params.require(:language).permit(
      :name, :short, :support_available, :abuse_support_available, :sortable_name
    )
  end
end
