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
    if params[:language_id]
      @language_id = Language.find_by_short(params[:language_id]).id 
    end
    @languages = Language.all(:order => :iso)
  end
  
  def create
    params[:translators].each_value do |attributes|
      unless attributes[:email].blank?
        language = Language.find(attributes[:language_id])
        user = User.find_by_email(attributes[:email])
        if user
          user.is_translator_for language
        else
          flash[:error] = "Sorry, we couldn't find a user with the email address: " + attributes[:email]
          redirect_to new_language_translator_path(language)
          return
        end
      end
    end 
    flash[:notice] = "Translators were added!"
    redirect_to translators_path      
  end
  
  def destroy
  end
   
end
