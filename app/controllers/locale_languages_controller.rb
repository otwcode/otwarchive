class LocaleLanguagesController < ApplicationController
  def index
    @locale_languages = LocaleLanguage.default_order
  end

  def new
    @locale_language = LocaleLanguage.new
    authorize @locale_language
  end

  def create
    @locale_language = LocaleLanguage.new(language_params)
    authorize @locale_language
    if @locale_language.save
      flash[:notice] = t("languages.successfully_added")
      redirect_to locale_languages_path
    else
      render action: "new"
    end
  end

  def edit
    @locale_language = LocaleLanguage.find_by(short: params[:id])
    authorize @locale_language
  end

  def update
    @locale_language = LocaleLanguage.find_by(short: params[:id])
    authorize @locale_language

    if @locale_language.update(permitted_attributes(@locale_language))
      flash[:notice] = t("languages.successfully_updated")
      redirect_to locale_languages_path
    else
      render action: "new"
    end
  end

  private

  def language_params
    params.require(:locale_language).permit(
      :name, :short, :support_available, :abuse_support_available, :sortable_name
    )
  end
end
