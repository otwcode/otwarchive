# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # Store the current user as a class variable in the User class,
  # so other models can access it with "User.current_user"
  before_filter :set_current_user
  def set_current_user
    User.current_user = current_user
    @current_user = current_user
  end

  #### -- GLOBALIZATION -- ####
  layout 'application'
  
  before_filter :set_locale  
  # Determines the user's language of choice
  def set_locale
    default_locale = 'en'
    request_language = request.env['HTTP_ACCEPT_LANGUAGE']
    request_language = request_language.nil? ? nil : 
      request_language[/[^,;]+/]
    @locale = params[:locale] || session[:locale] ||
              request_language || default_locale
    begin
      unless ArchiveConfig.SUPPORTED_LOCALES[@locale]
        flash[:warning] = "We don't currently support your locale, sorry, so 
            we're falling back to the default locale (#{LANGUAGE_NAMES[default_locale]}). Please contact our 
            volunteers committee if you'd be willing to help out as a translator!"
        redirect_to url_for(:overwrite_params => {:locale => default_locale})
      end
      session[:locale] = @locale
      Locale.set ArchiveConfig.SUPPORTED_LOCALES[@locale]      
      # prepend the user's locale to their view path
      prepend_view_path File.join(File.dirname(__FILE__), '..', "views/localized/#{@locale}")
    rescue
      Locale.set ArchiveConfig.SUPPORTED_LOCALES[default_locale]
    end  
  end 
  #### -- GLOBALIZATION -- ####

  #### -- AUTHORIZATION -- ####
  def is_registered_user?
    logged_in? || logged_in_as_admin?
  end
  
  def is_admin?
    logged_in_as_admin?
  end
  
  #### -- AUTHORIZATION -- ####


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ac9a60d7583c3455f6ac2ad6ba21d83e'
end
