class LanguagesController < ApplicationController
  def index
    @languages = Language.default_order
    @works_counts = Rails.cache.fetch("/v1/languages/work_counts/#{current_user.present?}", expires_in: 1.day) do
      WorkQuery.new.works_per_language(@languages.count)
    end
  end

  def new
    @language = Language.new
    authorize @language
  end

  def create
    authorize Language
    @language = Language.new(permitted_attributes(Language))
    if @language.save
      flash[:notice] = t("languages.successfully_added")
      redirect_to languages_path
    else
      render action: "new"
    end
  end

  def edit
    @language = Language.find_by!(short: params[:id])
    authorize @language
    return unless @language == Language.default

    flash[:error] = t("languages.cannot_edit_default")
    redirect_to languages_path
  end

  def update
    @language = Language.find_by!(short: params[:id])
    authorize @language

    if @language.update(permitted_attributes(@language))
      flash[:notice] = t("languages.successfully_updated")
      redirect_to languages_path
    else
      render action: "edit"
    end
  end

end
