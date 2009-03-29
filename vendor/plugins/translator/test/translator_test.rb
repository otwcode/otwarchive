require 'test_helper'

# Include the models/helpers directories on the load path.
[:models, :helpers, :controllers].each do |path|
  $:.unshift "#{File.dirname(__FILE__)}/fixtures/app/#{path}"
end

# sample AR model
require 'blog_post'
# sample ActionMailer
require 'blog_comment_mailer'
# sample controller
require 'blog_posts_controller'

# Set up simple routing for testing
ActionController::Routing::Routes.reload rescue nil
ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

# Test Translator functionality
class TranslatorTest < ActiveSupport::TestCase

  def setup
    # Create test locale bundle
    I18n.backend = I18n::Backend::Simple.new
    
    # tell the I18n library where to find your translations
    I18n.load_path += Dir.glob(File.join(File.dirname(__FILE__), 'locales', '*.{yml,rb}'))

    # reset the locale
    I18n.default_locale = :en
    I18n.locale = :en
    
    # Set up test env
    @controller = BlogPostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    super
  end
  
  ### ActionController Tests
  
  # Test that translate gets typical controller scoping
  def test_controller_simple
    get :index
    assert_response :success
    assert_not_nil assigns
    # Test that controller could translate
    assert_equal I18n.t('blog_posts.index.title'), assigns(:page_title)
    assert_equal I18n.translate('blog_posts.index.intro', :owner => "Ricky Rails"), assigns(:intro)
  end
  
  # Test that if something that breaks convention is still processed correctly
  # This case breaks with standard key hierarchy convention
  def test_controller_different_formats
    get :different_formats
    assert_response :success
    assert_not_nil assigns(:taglines)
    
    expected = "Hello i18n World" # copied from en.yml

    assigns(:taglines).each do |str|
      assert_equal expected, str
    end
  end
  
  # Test call to translate with default value
  def test_controller_with_defaults
    get :default_value
    assert_response :success
    assert_not_nil assigns(:title)
    
    # TODO: Need better way to check that the default was only returned as last resort.
    assert_equal 'the default', assigns(:title)
  end
  
  # TODO: Test bulk lookup
  def test_bulk_lookup
    # flunk
  end
  
  # Translator should raise an exception on a leading dot key to 
  # preserve Rails 2.3 behavior. It is caught & handled
  def test_leading_dot_key
    assert_raise Translator::TranslatorError do
      Translator.translate_with_scope(["blog_posts", "show"], ".category")
    end
  end
  
  # Test that first the most specific scope will be tried (controller.action) then
  # back off to just the outer scope (controller)
  def test_controller_shared_messages
    get :admin
    assert_response :redirect
    
    # Test that t should have tried the outer scope
    assert_equal I18n.t('blog_posts.flash.invalid_login'), flash[:error]
  end
  
  ### ActionView Tests
  
  # Test that translate works in Views. 
  # Also tests that a dotted key (".foo") can be accepted used, since
  # Rails 2.3 supports it
  def test_view_show
    get :show
    assert_response :success
    post_title = I18n.translate('blog_posts.show.title')
    post_body = I18n.t('blog_posts.show.body', :name => 'hobbes') # matches show.erb

    assert_match /#{post_title}/, @response.body
    assert_match /#{post_body}/, @response.body
  end
  
  # Test that layouts can pull strings
  def test_show_with_layout
    get :show_with_layout
    assert_response :success
    
    blog_title = I18n.t('layouts.blog_layout.blog_title')
    assert_match /#{blog_title}/, @response.body
  end
  
  # Test that partials pull strings from their own key
  def test_view_partial
    get :footer_partial
    assert_response :success
    
    footer = I18n.t('blog_posts.footer.copyright')
    assert_match /#{footer}/, @response.body
  end
  
  def test_header_partial
    get :header_partial
    assert_response :success
    
    blog_name = I18n.t('shared.header.blog_name')
    assert_match /#{blog_name}/, @response.body
  end
  
  # Test that view helpers inherit correct scoping
  def test_view_helpers
    get :archives
    assert_response :success
    
    archives_title = I18n.t('blog_posts.archives.title')
    assert_match /#{archives_title}/, @response.body
  end
  
  # Test that original behavior of TranslationHelper is not undone.
  # It adds a <span class="translation_missing"> that should still be there
  def test_missing_translation_show_in_span
    Translator.strict_mode(false)
    
    get :missing_translation
    assert_response :success

    # behavior added by TranslationHelper
    assert_match /span class="translation_missing"/, @response.body, "Should be a span tag translation_missing"
  end
  
  # Test that strict mode prevents TranslationHelper from adding span.
  def test_strict_mode_in_views
    Translator.strict_mode(true)
    
    get :missing_translation
    assert_response :error
    assert_match /18n::MissingTranslationData/, @response.body, "Exception should be for a missing translation"
  end
  
  ### ActionMailer Tests
  
  def test_mailer    
    mail = BlogCommentMailer.create_comment_notification
    # Subject is fetched from the mailer action
    subject = I18n.t('blog_comment_mailer.comment_notification.subject')
    
    # Signoff is fetched in the mail template (via addition to ActionView)
    signoff = I18n.t('blog_comment_mailer.comment_notification.signoff')
    
    assert_match /#{subject}/, mail.body
    assert_match /#{signoff}/, mail.body
  end
   
  ### ActiveRecord tests
  
  # Test that a model's method can call translate
  def test_model_calling_translate
    post = nil
    author = "Ricky"
    assert_nothing_raised do
      post = BlogPost.create(:title => "First Post!", :body => "Starting my new blog about RoR", :author => author)
    end
    assert_not_nil post
    
    assert_equal I18n.t('blog_post.byline', :author => author), post.written_by
  end
  
  # Test that the translate method is added as a class method too so that it can
  # be used in validate calls, etc.
  def test_class_method_translate
    
    url = "http://ricky.blog"
    # Call a static method
    assert_equal I18n.t('blog_post.permalink', :url => url), BlogPost.permalink(url)
  end
   
  ### TestUnit helpers
  
  def test_strict_mode
    Translator.strict_mode(true)
    
    # With strict mode on, exception should be thrown
    assert_raise I18n::MissingTranslationData do
      str = "Exception should be raised #{I18n.t('the_missing_key')}"
    end
    
    Translator.strict_mode(false)
    
    assert_nothing_raised do
      str = "Exception should not be raised #{I18n.t('the_missing_key')}"
    end
  end
  
  # Fetch a miss
  def test_assert_translated
    # Within the assert_translated block, any missing keys fail the test
    assert_raise Test::Unit::AssertionFailedError do
      assert_translated do
        str = "Exception should be raised #{I18n.t('the_missing_key')}"
      end
    end
    
    assert_nothing_raised do
      str = "Exception should not be raised #{I18n.t('the_missing_key')}"
    end
  end
  
  # Test that marker text appears in when using pseudo-translation
  def test_pseudo_translate
    Translator.pseudo_translate(true)
    
    # Create a blog post that uses translate to create a byline
    blog_post = BlogPost.create!(:author => "Ricky")
    assert_not_nil blog_post
    
    assert_match Translator.pseudo_prepend, blog_post.written_by, "Should start with prepend text"
    assert_match Translator.pseudo_append, blog_post.written_by, "Should end with append text"
  end
  
  # Test that markers can be changed
  def test_pseudo_translate_with_diff_markers
    Translator.pseudo_translate(true)
    
    start_marker = "!!"
    end_marker = "%%"
    
    # Set the new markers
    Translator.pseudo_prepend = start_marker
    Translator.pseudo_append = end_marker
    
    get :footer_partial
    assert_response :success

    # Test that the view has the pseudo-translated strings
    copyright = I18n.t('blog_posts.footer.copyright')
    assert_match /#{start_marker + copyright + end_marker}/, @response.body
  end
  
  # Test that if fallback mode is enabled, the default locale is used if
  # the set locale can't be found
  def test_fallback
    # Enable fallback mode
    Translator.fallback(true)
    
    # Set the locale to Spanish
    I18n.locale = :es
    
    # The index action fetchs 2 keys - 1 has a Spanish translation (intro), 1 does not
    get :index
    assert_response :success
    assert_not_nil assigns
    
    # Test that controller could translate the intro from spanish
    assert_equal I18n.t('blog_posts.index.intro', :owner => "Ricky Rails"), assigns(:intro)
    
    # Test that global strings are found correctly when they have a prefix
    assert_equal I18n.t('global.sub.key', :locale => :es), @controller.t('global.sub.key')
    
    # Should find the English version
    I18n.locale = :en # reset local so call to I18n pulls correct string
    assert_equal I18n.translate('blog_posts.index.title'), assigns(:page_title)
    
    # Test that global strings are found correctly when they have a prefix
    assert_equal I18n.t('global.sub.key', :locale => :en), @controller.t('global.sub.key')
  end
  
  # Test that fallback 
  def test_fallback_with_scoping_backoff
    
    # Enable fallback mode
    Translator.fallback(true)
    
    # Set the locale to Spanish
    I18n.locale = :es
    
    get :about
    assert_response :success
    
    # Test that the Spanish version was found
    bio = I18n.t('blog_posts.bio', :locale => :es)
    assert_match /#{bio}/, @response.body
    
    # Only English version of this string
    subscribe = I18n.t('blog_posts.subscribe_feed', :locale => :en)
    assert_match /#{subscribe}/, @response.body
  end
  
  # Test that we can set up a callback for missing translations
  def test_missing_translation_callback
    test_exception = nil
    test_key = nil
    test_options = nil
       
    Translator.set_missing_translation_callback do |ex, key, options|
      test_exception = ex
      test_key = key
      test_options = options
    end
    
    get :missing_translation
    assert_response :success
    assert_equal "missing_string", test_key
    assert_not_nil test_options
    assert_not_nil test_exception
  end
  
  # Test the generic translate method on Translator that does lookup without a scope, but includes fallback behavior.
  def test_generic_translate_methods
    assert_equal I18n.t('blog_posts.index.intro', :owner => "Ricky Rails"), Translator.translate('blog_posts.index.intro', :owner => "Ricky Rails")
    assert_equal I18n.t('blog_posts.footer.copyright'), Translator.t('blog_posts.footer.copyright')
  end
  
end