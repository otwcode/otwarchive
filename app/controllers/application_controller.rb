# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

PROFILER_SESSIONS_FILE = 'used_tags.txt'

class ApplicationController < ActionController::Base
  if ENV['RAILS_ENV'] == 'development' && ArchiveConfig.DEVELOPMENT_PROFILING_ENABLED
    # Inline profiling options
    def self.profiler_logging_path
      current_dir = File.split(__FILE__)[0]
      path = File.join(current_dir, '..', '..', 'tmp', 'performance')
      return path
    end

    def self.process(request, response)
      cookie_name = 'profile'
      profile = false
      if (cookies = request.headers['Cookie'])
        cookie_prefix = cookie_name + '='
        if cookies.include? cookie_prefix
          profiler_session_id = cookies[cookies.index(cookie_prefix)+cookie_prefix.length...cookies.length]
          profiler_session_id = profiler_session_id[0...profiler_session_id.index(';')||profiler_session_id.length] + "\n"
	  # Create log directory, if missing.
          unless File.directory? profiler_logging_path
            Dir.mkdir profiler_logging_path
          end
          profiler_sessions_file_name = File.join(profiler_logging_path, PROFILER_SESSIONS_FILE)
	  # Create the file for storing used session ids, if it doesn't exist.
          File.new(profiler_sessions_file_name, 'wb').close unless File.exists? profiler_sessions_file_name
	  # Then open it for reading.
          profiler_sessions_file = File.new(profiler_sessions_file_name, 'rb')
          used_ids_list = profiler_sessions_file.readlines()
          unless profiler_session_id == 'No' or used_ids_list.include? profiler_session_id
            profile = true
	    # We've only got a read handle. Reopen the file for appending in binary mode.
            profiler_sessions_file.reopen(profiler_sessions_file.path, 'ab')
	    # Add the current session ID to the list of used IDs.
            profiler_sessions_file.write(profiler_session_id)
          end
          profiler_sessions_file.close()
        end
      end
      if profile
	begin
	  require 'ruby-prof'
	rescue LoadError
	  # We just continue quietly without profiling if ruby-prof is not
	  # available.
	  profile = false
	end
      end
      if profile
	querystring = request.query_string || ''
	pathinfo = request.path_info || ''
        name = "#{Time.now} #{pathinfo} #{querystring.split('.')[0].gsub('/', '_')}.html"
        start = Time.now
	# We use this array to get data out of the profiler's closure.
	# It only ever holds the one element
        result = []
        profiler_results = RubyProf.profile do
          result.push super(request, response)
        end
        duration = Time.now - start
        f = File.new(File.join(profiler_logging_path, name), 'wb')
        RubyProf::GraphHtmlPrinter.new(profiler_results).print(f)
        f.close()
        return result[0]
      else
        super(request, response)
      end
    end
  end

  helper :all # include all helpers, all the time
  filter_parameter_logging :content, :password, :terms_of_service_non_production

  include ExceptionNotifiable

  include SanitizeParams
  before_filter :sanitize_params

  # store previous page in session to make redirecting back possible
  before_filter :store_location

  # Store the current user as a class variable in the User class,
  # so other models can access it with "User.current_user"
  before_filter :set_current_user
  def set_current_user
    User.current_user = logged_in_as_admin? ? current_admin : current_user
    @current_user = current_user
  end

  def load_collection
    @collection = Collection.find_by_name(params[:collection_id]) if params[:collection_id]
  end

  def collection_maintainers_only
    logged_in? && @collection && @collection.user_is_maintainer?(current_user) || access_denied
  end
  
  def collection_owners_only
    logged_in? && @collection && @collection.user_is_owner?(current_user) || access_denied
  end
  
  @over_anon_threshold = true if @over_anon_threshold.nil? 
  
  def get_page_title(fandom, author, title)
    @page_title = ""
    if logged_in? && !current_user.preference.work_title_format.blank?
      @page_title = current_user.preference.work_title_format
      @page_title.gsub!(/FANDOM/, fandom)
      @page_title.gsub!(/AUTHOR/, author)
      @page_title.gsub!(/TITLE/, title)
    else
      @page_title = title + " - " + author + " - " + fandom
    end
    @page_title += " [#{ArchiveConfig.APP_NAME}]"
  end
  
  ### GLOBALIZATION ###

#  before_filter :load_locales
#  before_filter :set_preferred_locale
  
#  I18n.backend = I18nDB::Backend::DBBased.new 
#  I18n.record_missing_keys = false # if you want to record missing translations

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
    return true if session[:adult] || logged_in_as_admin?
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
    if @check_visibility_of.respond_to?(:restricted) && @check_visibility_of.restricted && User.current_user == :false
      redirect_to new_session_path(:restricted => true)
    else
      is_hidden = @check_visibility_of.respond_to?(:visible) ? !@check_visibility_of.visible : @check_visibility_of.hidden_by_admin?
      can_view_hidden = logged_in_as_admin? || current_user_owns?(@check_visibility_of)
      access_denied if (is_hidden && !can_view_hidden)
    end
  end
  
  private
 # With thanks from here: http://blog.springenwerk.com/2008/05/set-date-attribute-from-dateselect.html
  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return Date.new(hash[attribute + '(1i)'].to_i, hash[attribute + '(2i)'].to_i, hash[attribute + '(3i)'].to_i)   
  end
  
  public
  
  #### -- AUTHORIZATION -- ####

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'ac9a60d7583c3455f6ac2ad6ba21d83e'
end
