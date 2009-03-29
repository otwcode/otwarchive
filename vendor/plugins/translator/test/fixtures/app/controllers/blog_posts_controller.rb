# Stub a Blog Posts controller
class BlogPostsController < ActionController::Base
  
  # Sets up view paths so tests will work
  before_filter :fix_view_paths

  # Simulate auth filter
  before_filter :authorize, :only => [:admin]

  layout "blog_layout", :only => :show_with_layout

  def index
    # Pull out sample strings for index to the fake blog
    @page_title = t('title')
    @intro = translate(:intro, :owner => "Ricky Rails")
    render :nothing => true, :layout => false
  end
  
  def show
    # Sample blog post
    render :template => "blog_posts/show"
  end
  
  def about
    # About page
    render :template => "blog_posts/about"
  end
  
  # Render the show action with a layout
  def show_with_layout
    render :template => "blog_posts/show"
  end
  
  # The archives action references a view helper
  def archives
    render :template => "blog_posts/archives"
  end
  
  # View that has a key that doesn't reference a valid string
  def missing_translation
    render :template => "blog_posts/missing_translation"
  end
  
  def different_formats
    # Get the same tagline using the different formats
    @taglines = []
    @taglines << t('global.sub.key') # dot-sep keys
    @taglines << t('sub.key', :scope => :global) # dot-sep keys with scope
    @taglines << t('key', :scope => 'global.sub') # string key with dot-sep scope
    @taglines << t(:key, :scope => 'global.sub') # symbol key with dot-sep score
    @taglines << t(:key, :scope => %w(global sub))
    render :nothing => true
  end
  
  # Partial template, but stored within this controller
  def footer_partial
    render :partial => "footer"
  end
  
  # Partial that is shared across controllers
  def header_partial
    render :partial => "shared/header"
  end

  def admin
    # Simulate an admin page that has a protection scheme
  end
  
  def default_value
    # Get a default value if the string isn't there
    @title = t('not_there', :default => 'the default')
    render :nothing => true
  end
  
  protected
  
  # Simulate an auth system that prevents login
  def authorize
    # set a flash with a common message
    flash[:error] = t('flash.invalid_login')
    redirect_to :action => :index
  end
  
  def fix_view_paths
    # Append the view path to get the correct views/partials
    self.append_view_path("#{File.dirname(__FILE__)}/../views")
  end
  
end