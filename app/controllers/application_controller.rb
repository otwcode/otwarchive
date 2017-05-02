PROFILER_SESSIONS_FILE = 'used_tags.txt'

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  include HtmlCleaner
  before_filter :sanitize_params

  # Authlogic login helpers
  helper_method :current_user
  helper_method :current_admin
  helper_method :logged_in?
  helper_method :logged_in_as_admin?

  # Title helpers
  helper_method :process_title

  # clear out the flash-being-set
  before_filter :clear_flash_cookie
  def clear_flash_cookie
    cookies.delete(:flash_is_set)
  end

  after_filter :check_for_flash
  def check_for_flash
    cookies[:flash_is_set] = 1 unless flash.empty?
  end

  before_filter :ensure_admin_credentials
  def ensure_admin_credentials
    if logged_in_as_admin?
      # if we are logged in as an admin and we don't have the admin_credentials
      # set then set that cookie
      cookies[:admin_credentials] = 1 unless cookies[:admin_credentials]
    else
      # if we are NOT logged in as an admin and we have the admin_credentials
      # set then delete that cookie
      cookies.delete :admin_credentials unless cookies[:admin_credentials].nil?
    end
  end

  # So if there is not a user_credentials cookie and the user appears to be logged in then
  # redirect to the logout page
  before_filter :logout_if_not_user_credentials
  def logout_if_not_user_credentials
    return unless logged_in? && cookies[:user_credentials].nil? && controller_name != "user_sessions"
    path = request.fullpath
    logger.error "Forcing logout #{path}"
    @user_session = UserSession.find
    @user_session.destroy if @user_session
    redirect_to lost_cookie_path(return_to_url: path)
  end


  # mark the flash as being set (called when flash is set)
  def set_flash_cookie(key=nil, msg=nil)
    cookies[:flash_is_set] = 1
  end
  # aliasing setflash for set_flash_cookie
  # def setflash (this is here in case someone is grepping for the definition of the method)
  alias :setflash :set_flash_cookie

  def current_user
    @current_user ||= current_user_session && current_user_session.record
  end

protected

  def record_not_found (exception)
    @message=exception.message
    respond_to do |f|
      f.html{ render :template => "errors/404", :status => 404 }
    end
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def logged_in?
    current_user.nil? ? false : true
  end

  def logged_in_as_admin?
    current_admin.nil? ? false : true
  end

  def guest?
    !(logged_in? || logged_in_as_admin?)
  end

  def process_title(string)
  	string = string.humanize.titleize

  	string = string.sub("Faq", "FAQ")
  	string = string.sub("Tos", "TOS")
  	string = string.sub("Dmca", "DMCA")
  	return string
  end

public

  before_filter :fetch_admin_settings
  def fetch_admin_settings
    if Rails.env.development?
      @admin_settings = AdminSetting.first
    else
      @admin_settings = Rails.cache.fetch("admin_settings"){AdminSetting.first}
    end
  end

  before_filter :load_admin_banner
  def load_admin_banner
    if Rails.env.development?
      @admin_banner = AdminBanner.where(:active => true).last
    else
      # http://stackoverflow.com/questions/12891790/will-returning-a-nil-value-from-a-block-passed-to-rails-cache-fetch-clear-it
      # Basically we need to store a nil separately.
      @admin_banner = Rails.cache.fetch("admin_banner") do
        banner = AdminBanner.where(:active => true).last
        banner.nil? ? "" : banner
      end
      @admin_banner = nil if @admin_banner == ""
    end
  end

  # store previous page in session to make redirecting back possible
  # if already redirected once, don't redirect again.
  before_filter :store_location
  def store_location
    if session[:return_to] == "redirected"
      Rails.logger.debug "Return to back would cause infinite loop"
      session.delete(:return_to)
    else
      session[:return_to] = request.fullpath
      Rails.logger.debug "Return to: #{session[:return_to]}"
    end
  end

  # Redirect to the URI stored by the most recent store_location call or
  # to the passed default.
  def redirect_back_or_default(default = root_path)
    back_url = params[:user_session][:return_to_url] if params[:user_session]
    back = session[:return_to]
    session.delete(:return_to)
    if back_url
      Rails.logger.debug "Returning over riding return to #{back} with #{back_url}"
      back = back_url
    end
    if back
      Rails.logger.debug "Returning to #{back}"
      session[:return_to] = "redirected"
      redirect_to(back) and return
    else
      Rails.logger.debug "Returning to default (#{default})"
      redirect_to(default) and return
    end
  end

  def after_sign_in_path_for(resource)
    admin_users_path
  end

  def authenticate_admin!
    if admin_signed_in?
      super
    else
      redirect_to root_path, notice: "I'm sorry, only an admin can look at that area"
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end

  # Filter method - keeps users out of admin areas
  def admin_only
    authenticate_admin! || admin_only_access_denied
  end

  # Filter method to prevent admin users from accessing certain actions
  def users_only
    logged_in? || access_denied
  end

  # Filter method - requires user to have opendoors privs
  def opendoors_only
    (logged_in? && permit?("opendoors")) || access_denied
  end

  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied(options ={})
    store_location
    if logged_in?
      destination = options[:redirect].blank? ? user_path(current_user) : options[:redirect]
      flash[:error] = ts "Sorry, you don't have permission to access the page you were trying to reach."
      redirect_to destination
    else
      destination = options[:redirect].blank? ? new_user_session_path : options[:redirect]
      flash[:error] = ts "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
      redirect_to destination
    end
    false
  end

  def admin_only_access_denied
    flash[:error] = ts("I'm sorry, only an admin can look at that area.")
    redirect_to root_path
    false
  end

  # Filter method - prevents users from logging in as admin
  def user_logout_required
    if logged_in?
      flash[:notice] = 'Please log out of your user account first!'
      redirect_to root_path
    end
  end

  # Prevents admin from logging in as users
  def admin_logout_required
    if logged_in_as_admin?
      flash[:notice] = 'Please log out of your admin account first!'
      redirect_to root_path
    end
  end

  # Hide admin banner via cookies
  before_filter :hide_banner
  def hide_banner
    if params[:hide_banner]
      session[:hide_banner] = true
    end
  end

  # Store the current user as a class variable in the User class,
  # so other models can access it with "User.current_user"
  before_filter :set_current_user
  def set_current_user
    User.current_user = logged_in_as_admin? ? current_admin : current_user
    @current_user = current_user
    unless current_user.nil?
      @current_user_subscriptions_count, @current_user_visible_work_count, @current_user_bookmarks_count, @current_user_owned_collections_count, @current_user_challenge_signups_count, @current_user_offer_assignments, @current_user_unposted_works_size=
             Rails.cache.fetch("user_menu_counts_#{current_user.id}",
                               expires_in: 2.hours,
                               race_condition_ttl: 5) { "#{current_user.subscriptions.count}, #{current_user.visible_work_count}, #{current_user.bookmarks.count}, #{current_user.owned_collections.count}, #{current_user.challenge_signups.count}, #{current_user.offer_assignments.undefaulted.count + current_user.pinch_hit_assignments.undefaulted.count}, #{current_user.unposted_works.size}" }.split(",").map(&:to_i)
    end
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

  def not_allowed(fallback=nil)
    flash[:error] = ts("Sorry, you're not allowed to do that.")
    redirect_to (fallback || root_path) rescue redirect_to '/'
  end


  @over_anon_threshold = true if @over_anon_threshold.nil?

  def get_page_title(fandom, author, title, options = {})
    # truncate any piece that is over 15 chars long to the nearest word
    if options[:truncate]
      fandom = fandom.gsub(/^(.{15}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
      author = author.gsub(/^(.{15}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
      title = title.gsub(/^(.{15}[\w.]*)(.*)/) {$2.empty? ? $1 : $1 + '...'}
    end

    @page_title = ""
    if logged_in? && !current_user.preference.try(:work_title_format).blank?
      @page_title = current_user.preference.work_title_format
      @page_title.gsub!(/FANDOM/, fandom)
      @page_title.gsub!(/AUTHOR/, author)
      @page_title.gsub!(/TITLE/, title)
    else
      @page_title = title + " - " + author + " - " + fandom
    end

    @page_title += " [#{ArchiveConfig.APP_NAME}]" unless options[:omit_archive_name]
    @page_title.html_safe
  end

  # Define media for fandoms menu
  before_filter :set_media
  def set_media
    uncategorized = Media.uncategorized
    @menu_media = Media.by_name - [Media.find_by_name(ArchiveConfig.MEDIA_NO_TAG_NAME), uncategorized] + [uncategorized]
  end

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
    params[:anchor] = "comments" if (params[:show_comments] && params[:anchor].blank?)
    Rails.logger.debug "Added anchor #{params[:anchor]}"
    return true if session[:adult] || logged_in_as_admin?
    return false unless current_user
    return true if current_user.is_author_of?(@work)
    return true if current_user.preference && current_user.preference.adult
    return false
  end

  def use_caching?
    %w(staging production).include?(Rails.env) && @admin_settings.enable_test_caching?
  end

  protected

  # Prevents banned and suspended users from adding/editing content
  def check_user_status
    if current_user.is_a?(User) && (current_user.suspended? || current_user.banned?)
      if current_user.suspended?
        flash[:error] = t('suspension_notice', default: "Your account has been suspended until %{suspended_until}. You may not add or edit content until your suspension has been resolved. Please <a href=\"#{new_abuse_report_path}\">contact Abuse</a> for more information.", suspended_until: localize(current_user.suspended_until)).html_safe
      else
        flash[:error] = t('ban_notice', default: "Your account has been banned. You are not permitted to add or edit archive content. Please <a href=\"#{new_abuse_report_path}\">contact Abuse</a> for more information.").html_safe
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
  def check_ownership_or_admin
     return true if logged_in_as_admin?
     access_denied(:redirect => @check_ownership_of) unless current_user_owns?(@check_ownership_of)
  end

  # Make sure the user is allowed to see a specific page
  # includes a special case for restricted works and series, since we want to encourage people to sign up to read them
  def check_visibility
    if @check_visibility_of.respond_to?(:restricted) && @check_visibility_of.restricted && User.current_user.nil?
      redirect_to login_path(:restricted => true)
    elsif @check_visibility_of.is_a? Skin
      access_denied unless logged_in_as_admin? || current_user_owns?(@check_visibility_of) || @check_visibility_of.official?
    else
      is_hidden = (@check_visibility_of.respond_to?(:visible) && !@check_visibility_of.visible) ||
                  (@check_visibility_of.respond_to?(:visible?) && !@check_visibility_of.visible?) ||
                  (@check_visibility_of.respond_to?(:hidden_by_admin?) && @check_visibility_of.hidden_by_admin?)
      can_view_hidden = logged_in_as_admin? || current_user_owns?(@check_visibility_of)
      access_denied if (is_hidden && !can_view_hidden)
    end
  end

  # Make sure user is allowed to access tag wrangling pages
  def check_permission_to_wrangle
    if @admin_settings.tag_wrangling_off? && !logged_in_as_admin?
      flash[:error] = "Wrangling is disabled at the moment. Please check back later."
      redirect_to root_path
    else
      logged_in_as_admin? || permit?("tag_wrangler") || access_denied
    end
  end

  private
 # With thanks from here: http://blog.springenwerk.com/2008/05/set-date-attribute-from-dateselect.html
  def convert_date(hash, date_symbol_or_string)
    attribute = date_symbol_or_string.to_s
    return Date.new(hash[attribute + '(1i)'].to_i, hash[attribute + '(2i)'].to_i, hash[attribute + '(3i)'].to_i)
  end

  public

  def valid_sort_column(param, model='work')
    allowed = []
    if model.to_s.downcase == 'work'
      allowed = ['author', 'title', 'date', 'created_at', 'word_count', 'hit_count']
    elsif model.to_s.downcase == 'tag'
      allowed = ['name', 'created_at', 'suggested_fandoms', 'taggings_count_cache']
    elsif model.to_s.downcase == 'collection'
      allowed = ['collections.title', 'collections.created_at']
    elsif model.to_s.downcase == 'prompt'
      allowed = %w(fandom created_at prompter)
    elsif model.to_s.downcase == 'claim'
      allowed = %w(created_at claimer)
    end
    !param.blank? && allowed.include?(param.to_s.downcase)
  end

  def set_sort_order
    # sorting
    @sort_column = (valid_sort_column(params[:sort_column],"prompt") ? params[:sort_column] : 'id')
    @sort_direction = (valid_sort_direction(params[:sort_direction]) ? params[:sort_direction] : 'DESC')
    if !params[:sort_direction].blank? && !valid_sort_direction(params[:sort_direction])
      params[:sort_direction] = 'DESC'
    end
    @sort_order = @sort_column + " " + @sort_direction
  end

  def valid_sort_direction(param)
    !param.blank? && ['asc', 'desc'].include?(param.to_s.downcase)
  end

  #### -- AUTHORIZATION -- ####

  protect_from_forgery

end
