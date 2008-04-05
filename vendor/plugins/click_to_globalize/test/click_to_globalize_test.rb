require 'test/test_helper'
require 'test/unit'
require 'vendor/plugins/click_to_globalize/test/test_helper'

class ClickToGlobalizeController < ApplicationController
  def rescue_action(e) raise e end;
  def index
    Locale.set(params[:locale])
    hello_world = Translation.find_by_tr_key_and_language_id(params[:key], params[:language_id])
    @greet = hello_world.tr_key.t
    render :nothing => true, :status => 200
  end
end
module ClickToGlobalizeHelper; end

ApplicationHelper.class_eval do
  def controller
    @controller = ClickToGlobalizeController.new
    @controller
  end
end

class ClickToGlobalizeTest < Test::Unit::TestCase
  include Globalize
  include ApplicationHelper

  def setup
    assert_nil(Locale.send(:class_variable_set, :@@active, nil))
    
    # TODO load w/ #inject
    @hello_world  = Translation.find(1)
    @ciao_mondo   = Translation.find(2)
    @good_morning = Translation.find(3)

    @default_locale = Locale.new('en-US')
    @italian_locale = Locale.new('it-IT')

    @partial_path   = 'shared/_click_to_globalize'
    @base_language  = {:english => 'en-US'}
    @languages      = {:english => 'en-US', :italian => 'it-IT'}
    @new_languages  = {:spanish => 'es-ES', :french => 'fr-FR'}
    
    @inline = {:textile  => 'textilize_without_paragraph( @formatted_value )',
               :markdown => 'markdown( @formatted_value )',
               :other    => '@formatted_value'}

    @locale_controller = LocaleController.new

    @controller = ClickToGlobalizeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  # LOCALE_OBSERVER
  def test_locale_observer_init
    lo = LocaleObserver.new
    assert_not_nil(lo)
    assert_kind_of(LocaleObserver, lo)
    
    assert_not_nil(lo.translations)
    assert(lo.translations.empty?)
    assert_kind_of(Hash, lo.translations)
  end
  
  def test_locale_observer_update
    lo = LocaleObserver.new
    lo.update(nil, nil)
    assert_equal({nil => nil}, lo.translations)
    assert_nil(lo.translations[nil])
    lo.instance_variable_set(:@translations, {})
    
    lo.update(@hello_world.tr_key, @hello_world.text)
    assert_equal({@hello_world.tr_key => @hello_world.text}, lo.translations)
    assert_equal(@hello_world.text, lo.translations[@hello_world.tr_key])
    
    lo.update(@ciao_mondo.tr_key, @ciao_mondo.text)
    assert_equal({@ciao_mondo.tr_key => @ciao_mondo.text}, lo.translations)
    assert_equal(@ciao_mondo.text, lo.translations[@ciao_mondo.tr_key])
    
    lo.update(@good_morning.tr_key, @good_morning.text)
    assert_equal({@ciao_mondo.tr_key => @ciao_mondo.text, @good_morning.tr_key => @good_morning.text}, lo.translations)
    assert_equal(@good_morning.text, lo.translations[@good_morning.tr_key])
  end
  
  def test_locale_observer_missing_translations_setter
    lo = LocaleObserver.new
    assert_raise(NoMethodError) { lo.translations = {} }
  end
  
  # LOCALE
  def test_locale_active
    assert_nil(Locale.send(:class_variable_get, :@@active))
    
    base_language_code = Locale.send(:class_variable_get, :@@base_language_code)
    
    assert_not_nil(base_language_code)
    assert_kind_of(RFC_3066, base_language_code)
    
    assert_not_nil(base_language_code.locale)
    assert_kind_of(String, base_language_code.locale)
    assert_equal(@default_locale.code, base_language_code.locale)
    
    assert_not_nil(Locale.active)
    assert_not_nil(Locale.send(:class_variable_get, :@@active))
    assert_kind_of(Locale, Locale.active)
    assert(Locale.active?)
    
    assert_kind_of(Country, Locale.country)
    assert_equal(@default_locale.country.code, Locale.country.code)
    
    assert_equal(Locale.base_language, Locale.active.language)
    assert_equal(@default_locale.language.code, Locale.language_code)
    
    assert_equal(@default_locale.code, Locale.active.code)
  end
  
  def test_locale_set
    assert_nil(Locale.send(:class_variable_get, :@@active))
    
    Locale.set(@italian_locale.code)
    assert_not_nil(Locale.send(:class_variable_get, :@@active))
    assert_not_nil(Locale.active)
    
    assert_not_nil(Locale.country)
    assert_equal(@italian_locale.country.code, Locale.country.code)
    
    assert_not_equal(Locale.base_language, Locale.active.language)
    assert_equal(@italian_locale.language.code, Locale.language_code)
    
    assert_equal(@italian_locale.code, Locale.active.code)
  end
  
  def test_locale_method_aliases
    assert(Locale.respond_to?(:__translate))
    assert(Locale.respond_to?(:translate))
  end
  
  def test_locale_observers
    assert_kind_of(Set, Locale.observers)
    
    lo = LocaleObserver.new
    assert(Locale.observers.empty?)

    Locale.add_observer(lo)
    assert_equal(1, Locale.observers.size)
    
    Locale.add_observer(lo) #re-add
    assert_equal(1, Locale.observers.size)
    
    loo = lo.dup
    Locale.add_observer(loo)
    assert_equal(2, Locale.observers.size)
    
    Locale.notify_observers(@hello_world.tr_key, @hello_world.text)
    Locale.observers.each do |observer|
      assert_not_nil(observer.translations)
      assert_equal(1, observer.translations.size)
      assert_equal(@hello_world.text, observer.translations[@hello_world.tr_key])
    end
    
    Locale.notify_observers(@ciao_mondo.tr_key, @ciao_mondo.text)
    Locale.observers.each do |observer|
      assert_not_nil(observer.translations)
      assert_equal(1, observer.translations.size)
      assert_equal(@ciao_mondo.text, observer.translations[@ciao_mondo.tr_key])
    end
    
    Locale.remove_observer(loo)
    assert_equal(1, Locale.observers.size)
    Locale.remove_observer(loo) #delete again
    assert_equal(1, Locale.observers.size)
    
    Locale.remove_observer(lo)
    assert(Locale.observers.empty?)
  end
  
  def test_locale_notify_with_nil_observer
    assert(Locale.observers.empty?)
    
    Locale.add_observer(nil)
    assert_equal(1, Locale.observers.size)
    assert_raise(NoMethodError) { Locale.notify_observers(@hello_world.tr_key, @hello_world.text) }
    
    Locale.remove_observer(nil)
    assert(Locale.observers.empty?)
    assert_nothing_raised(NoMethodError) { Locale.notify_observers(@hello_world.tr_key, @hello_world.text) }
  end
  
  def test_locale_translate
    assert(Locale.observers.empty?)
    lo = LocaleObserver.new
    loo = lo.dup
    
    Locale.add_observer(lo)
    Locale.add_observer(loo)
    assert_equal(2, Locale.observers.size)
    
    assert_not_nil(Locale.active)
    assert_equal(@hello_world.text, @hello_world.tr_key.t)
    
    Locale.observers.each do |observer|
      assert_not_nil(observer.translations)
      assert_equal(1, observer.translations.size)
      assert_equal(@hello_world.text, observer.translations[@hello_world.tr_key])
    end
  end
  
  def test_formatting_set
    assert_nothing_raised(ArgumentError) { Locale.formatting = :textile }
    assert_equal(:textile, Locale.formatting)
    
    assert_nothing_raised(ArgumentError) { Locale.formatting = :markdown }
    assert_equal(:markdown, Locale.formatting)
    
    assert_raise(NoMethodError) { Locale.formatting = nil }
    assert_raise(ArgumentError) { Locale.formatting = :unknown }
  end
  
  def test_formatting_method
    Locale.formatting = :textile
    assert_equal(:textilize_without_paragraph, Locale.formatting_method)

    Locale.formatting = :markdown
    assert_equal(:markdown, Locale.formatting_method) if Locale.markdown?
  end

  def test_textile
    if Object.const_defined?(:RedCloth)
      assert(Locale.textile?)
    else
      assert(!Locale.textile?)
    end
  end
  
  def test_markdown
    if Object.const_defined?(:BlueCloth)
      assert(Locale.markdown?)
    else
      assert(!Locale.markdown?)
    end
  end
  
  # HELPER
  def test_helper_partial
    assert_equal(@partial_path, Helper.send(:class_variable_get, :@@partial))
  end
  
  def ignore_test_helper_in_place_globalizer
    assert false
  end
      
  def test_helper_languages
    ApplicationController.languages = @languages
    assert_equal(@languages, languages)
  end
  
  def ignore_test_helper_languages_menu
    assert false
  end
  
  # CONTROLLER
  def test_controller_deprecated_globalize
    assert @controller.class.globalize?
  end
  
  def test_controller_globalize
    assert @controller.globalize?
  end
  
  def test_languages_set
    assert_not_nil(ApplicationController.languages)
    ApplicationController.languages = nil
    assert_equal(@languages, ApplicationController.languages)
        
    ApplicationController.languages = @languages
    assert_not_nil(ApplicationController.languages)
    assert_kind_of(Hash, ApplicationController.languages)
    assert_equal(@languages, ApplicationController.languages)
    
    ApplicationController.languages = @new_languages
    assert_not_nil(ApplicationController.languages)
    assert_kind_of(Hash, ApplicationController.languages)
    assert_equal(@new_languages.merge(@base_language), ApplicationController.languages)
    
    ApplicationController.languages = @languages # re-assign
    assert_equal(@languages, ApplicationController.languages)

    ApplicationController.languages = @new_languages
    assert_equal(@new_languages.merge(@base_language), ApplicationController.languages)
  end
  
  def test_languages
    ApplicationController.languages = @languages
    languages = ApplicationController.languages
    assert_not_nil(languages)
    assert_kind_of(Hash, languages)
    assert_equal(@languages, languages)
    languages.each do |language, locale|
      assert_not_nil(language)
      assert_kind_of(Symbol, language)
      assert_equal(@languages[language], languages[language])
      
      assert_not_nil(locale)
      assert_kind_of(String, locale)
    end
  end
  
  def test_formatting_set
    assert_nothing_raised(ArgumentError) { ApplicationController.formatting :textile }
    assert_equal(:textile, Locale.formatting)
    
    assert_nothing_raised(ArgumentError) { ApplicationController.formatting :markdown }
    assert_equal(:markdown, Locale.formatting) if Locale.markdown?
    
    assert_raise(NoMethodError) { ApplicationController.formatting nil }
    assert_raise(ArgumentError) { ApplicationController.formatting :unknown }
  end
  
  def test_controller_observe_locale
    get :index, {:key => @hello_world.tr_key, :language_id => 1, :locale => @default_locale.code}
    assert_response :success

    assert_not_nil(@request.session[:__globalize_translations])
    assert(!@request.session[:__globalize_translations].empty?)
    assert_equal(1, @request.session[:__globalize_translations].size)
    assert_equal(@hello_world.text, @request.session[:__globalize_translations][@hello_world.tr_key])
  end
  
  # LOCALE_CONTROLLER
  def test_check_globalize
    assert(@locale_controller.send(:check_globalize))
  end
  
  def test_clear_cache
    @locale_controller.send(:clear_cache)
    assert_equal({}, Locale.send(:class_variable_get, :@@cache))
  end
  
  def test_inline
    Locale.formatting = :textile
    assert_equal(@inline[:textile], @locale_controller.send(:inline))
    
    Locale.formatting = :markdown
    assert_equal(@inline[:markdown], @locale_controller.send(:inline)) if Locale.markdown?
  end
end