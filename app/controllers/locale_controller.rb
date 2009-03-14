class LocaleController < ApplicationController
  def set
    if params[:locale]
      session[:locale] = params[:locale]     
    end
    redirect_to :back rescue redirect_to '/'
  end 
end