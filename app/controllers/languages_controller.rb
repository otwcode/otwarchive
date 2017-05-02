class LanguagesController < ApplicationController
  before_filter :check_permission, only: [:new, :create, :edit, :update]

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
    @language = Language.new(language_params)
    if @language.save
      flash[:notice] = t('successfully_added', default: 'Language was successfully added.')
      redirect_to languages_path
    else
      render action: "new"
    end
  end

  def edit
    @language = Language.find_by_short(params[:id])
  end

  def update
    @language = Language.find_by_short(params[:id])
    if @language.update_attributes(language_params)
      flash[:notice] = t('successfully_updated', default: 'Language was successfully updated.')
      redirect_to @language
    else
      render action: "new"
    end
  end

  private
  def language_params
    params.require(:language).permit(
      :name, :short, :support_available, :abuse_support_available
    )
  end
end
