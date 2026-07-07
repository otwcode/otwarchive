class LocaleLanguagesController < ApplicationController
  def index
    authorize LocaleLanguage
    @locale_languages = LocaleLanguage.default_order
  end

  def new
    @locale_language = LocaleLanguage.new
    authorize @locale_language
  end

  def create
    authorize LocaleLanguage
    @locale_language = LocaleLanguage.new(permitted_attributes(LocaleLanguage))
    if @locale_language.save
      flash[:notice] = t("locale_languages.successfully_added")
      redirect_to locale_languages_path
    else
      render action: "new"
    end
  end

  def edit
    @locale_language = LocaleLanguage.find_by!(short: params[:id])
    authorize @locale_language
    return unless @locale_language == LocaleLanguage.default

    flash[:error] = t("locale_languages.cannot_edit_default")
    redirect_to locale_languages_path
  end

  def update
    @locale_language = LocaleLanguage.find_by!(short: params[:id])
    authorize @locale_language

    if @locale_language.update(permitted_attributes(@locale_language))
      flash[:notice] = t("locale_languages.successfully_updated")
      redirect_to locale_languages_path
    else
      render action: "edit"
    end
  end
end
