# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  filter_parameter_logging :content, :password

  include ExceptionNotifiable

  include SanitizeParams
  before_filter :sanitize_params

  # store previous page in session to make redirecting back possible
  before_filter :store_location

  # Store the current user as a class variable in the User class,
  # so other models can access it with "User.current_user"
  before_filter :set_current_user
  def set_current_user
    User.current_user = current_user
    @current_user = current_user
  end
  
  ### GLOBALIZATION ###

  before_filter :load_locales
  before_filter :set_preferred_locale
  
  I18n.backend = I18nDB::Backend::DBBased.new 
  I18n.record_missing_keys = true # if you want to record missing translations

  protected

  def load_locales
    @loaded_locales ||= Locale.find(:all, :order => :iso)
  end

  # Sets the locale
  def set_preferred_locale
    # Loading the current locale
    if session[:locale] && @loaded_locales.detect { |loc| loc.iso == session[:locale]}
      set_locale session[:locale].to_sym
    else
      set_locale Locale.find_main_cached.iso.to_sym
    end
    @current_locale = Locale.find_by_iso(I18n.locale.to_s)  
  end
  
  ### -- END GLOBALIZATION -- ###
  
  public

  #### -- AUTHORIZATION -- #### 
  
  # It is just much easier to do this here than to try to stuff variable values into a constant in environment.rb
  before_filter :set_redirects
  def set_redirects
    @logged_in_redirect = url_for(current_user) if current_user.is_a?(User)
    @logged_out_redirect = url_for({:controller => 'session', :action => 'new'})
  end
  
  def is_registered_user?
    logged_in? || logged_in_as_admin?
  end
  
  def is_admin?
    logged_in_as_admin?
  end
  
  def see_adult?
    return true if session[:adult]
    return false if current_user == :false
    return true if current_user.is_author_of?(@work)
    return true if current_user.preference && current_user.preference.adult
    return false
  end

  protected
   
  # Prevents banned and suspended users from adding/editing content
  def check_user_status
    if current_user.is_a?(User) && (current_user.suspended? || current_user.banned?)
      if current_user.suspended? 
        flash[:error] = t('suspension_notice', :default => "Your account has been suspended. You may not add or edit content until your suspension has been resolved. Please contact us for more information.")
     else
        flash[:error] = t('ban_notice', :default => "Your account has been banned. You are not permitted to add or edit archive content. Please contact us for more information.")
     end
      redirect_to current_user
    end
  end
  
  # Does the current user own a specific object?
  def current_user_owns?(item)
  	!item.nil? && current_user.is_a?(User) && (item.is_a?(User) ? current_user == item : current_user.is_author_of?(item))    
  end
  
  # Make sure a specific object belongs to the current user and that they have permission
  # to view, edit or delete it
  def check_ownership 	
  	access_denied(:redirect => @check_ownership_of) unless current_user_owns?(@check_ownership_of)
  end
  
  # Make sure the user is allowed to see a specific page
  # includes a special case for restricted works and series, since we want to encourage people to sign up to read them
  def check_visibility
    if @check_visibility_of.respond_to?(:restricted) && @check_visibility_of.restricted && !logged_in?
      redirect_to new_session_path(:restricted => true)
    else
      is_hidden = @check_visibility_of.respond_to?(:visible) ? !@check_visibility_of.visible : @check_visibility_of.hidden_by_admin?
      can_view_hidden = is_admin? || current_user_owns?(@check_visibility_of)
      access_denied if (is_hidden && !can_view_hidden)
    end
  end
  
  public
  
  #### -- AUTHORIZATION -- ####

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'ac9a60d7583c3455f6ac2ad6ba21d83e'
end