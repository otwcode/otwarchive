class TranslatorsController < ApplicationController
  
  permit "translation_admin", :permission_denied_message => "Sorry, the page you tried to access is for translation admins only."
  
  def index
    if @locale = Locale.find_by_iso(params[:locale_id])
      @translators = @locale.has_translators
    else
      @translators = Role.find_all_by_authorizable_type('Locale').collect(&:users).flatten.uniq
    end
  end
  
  def show
    @translator = User.find_by_login(params[:id])
  end
  
  def new
    if params[:locale_id]
      @locale_id = Locale.find_by_iso(params[:locale_id]).id 
    end
    @locales = Locale.all(:order => :iso)
  end
  
  def create
    params[:translators].each_value do |attributes|
      unless attributes[:email].blank?
        locale = Locale.find(attributes[:locale_id])
        user = User.find_by_email(attributes[:email])
        if user
          user.is_translator_for locale
        else
          flash[:error] = t('user_not_found', :default => "Sorry, we couldn't find a user with the email address: {{email}}", :email => attributes[:email])
          redirect_to new_locale_translator_path(locale)
          return
        end
      end
    end 
    flash[:notice] = t('translators_added', :default => "Translators were added!")
    redirect_to translators_path      
  end
  
  def destroy
  end
   
end
