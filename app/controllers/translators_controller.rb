class TranslatorsController < ApplicationController
  
  permit "translation_admin", :permission_denied_message => "Sorry, the page you tried to access is for translation admins only."
  
  def index
    if @language = Language.find_by_short(params[:language_id])
      @translators = @language.has_translators
    else
      @translators = @loaded_locales.collect(&:has_translators).flatten.uniq
    end
  end
  
  def show
    @translator = User.find_by_login(params[:id])
  end
  
  def new
  end
  
  def create
  end
  
  def destroy
  end
   
end
