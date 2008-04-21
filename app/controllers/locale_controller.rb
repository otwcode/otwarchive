class LocaleController < ApplicationController
  def set
    Locale.set(SUPPORTED_LOCALES[params[:id]]) if params[:id]
    session[:locale] = Locale.active.language.code
    session[:locale_changed] = true
    logger.debug("[#{Time.now.to_s(:db)}] - Set current Locale on #{Locale.language}")
    redirect_to :back
  end 
end