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
    @language = Language.new(language_params)
    authorize @language
    if @language.save
      flash[:notice] = t("languages.successfully_added")
      redirect_to languages_path
    else
      render action: "new"
    end
  end

  def edit
    @language = Language.find_by(short: params[:id])
    authorize @language
  end

  def update
    @language = Language.find_by(short: params[:id])
    authorize @language
      
    if !policy(@language).can_edit_non_abuse_fields? && (@language.name != language_params[:name] || @language.short != language_params[:short] || @language.sortable_name != language_params[:sortable_name] || @language.support_available != (language_params[:support_available] == "1"))
      flash[:error] = t("languages.update.non_abuse_field_error")
      redirect_to languages_path
      return
    end

    if !policy(@language).can_edit_abuse_fields? && (@language.abuse_support_available != (language_params[:abuse_support_available] == "1"))
      flash[:error] = t("languages.update.abuse_field_error")
      redirect_to languages_path
      return
    end

    if @language.update(language_params)
      flash[:notice] = t("languages.successfully_updated")
      redirect_to languages_path
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
