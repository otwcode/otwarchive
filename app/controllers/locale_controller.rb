class LocaleController < ApplicationController
  def set
    if params[:url]
      redirect_to params[:url]     
    else
      redirect_to :back
    end
  end 
end