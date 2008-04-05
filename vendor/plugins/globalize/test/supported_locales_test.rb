require File.dirname(__FILE__) + '/test_helper'

class SupportedLocalesTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
    @supported_locales = ['es-ES', 'he-IL']
  end

  def test_base_locale_default_is_en_US
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal 'en', SupportedLocales.base_language_code
    assert_equal 'US', SupportedLocales.base_locale.country.code
    assert_equal 'en-US', SupportedLocales.base_locale_code
    assert_equal 'en-US', SupportedLocales.base_locale.code
    assert_equal 'English', SupportedLocales.base_english_name
    assert_equal 'English', SupportedLocales.base_native_name
  end

  def test_base_locale_is_automatically_added_to_supported_locales_if_not_present
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales, 'pl-PL')
    assert_equal 'pl', SupportedLocales.base_language_code
    assert_equal 'PL', SupportedLocales.base_locale.country.code
    assert_equal 'pl-PL', SupportedLocales.base_locale_code
    assert_equal 'pl-PL', SupportedLocales.base_locale.code
    assert_equal 'język polski', SupportedLocales.base_native_name
    assert_equal 'Polish', SupportedLocales.base_english_name

    assert SupportedLocales.supported?('pl-PL')
    assert SupportedLocales.supported?('pl')
    assert SupportedLocales.supported_locales.any? {|l| l.code == 'pl-PL'}
    assert SupportedLocales.supported_locale_codes.any? {|l| l == 'pl-PL'}
    assert SupportedLocales.supported_english_language_names.any? {|l| l == 'Polish'}
    assert SupportedLocales.supported_native_language_names.any? {|l| l == 'język polski'}
  end

  def test_base_locale_is_automatically_added_to_active_locales_if_not_present
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales, 'pl-PL')

    assert SupportedLocales.active?('pl-PL')
    assert SupportedLocales.active?('pl')
    assert SupportedLocales.active_locales.any? {|l| l.code == 'pl-PL'}
    assert SupportedLocales.active_locale_codes.any? {|l| l == 'pl-PL'}
    assert SupportedLocales.active_english_language_names.any? {|l| l == 'Polish'}
    assert SupportedLocales.active_native_language_names.any? {|l| l == 'język polski'}
  end

  def test_default_locale_default_is_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal SupportedLocales.base_language_code, SupportedLocales.default_language_code
    assert_equal SupportedLocales.base_locale.country.code, SupportedLocales.default_locale.country.code
    assert_equal SupportedLocales.base_locale_code, SupportedLocales.default_locale_code
    assert_equal SupportedLocales.base_locale.code, SupportedLocales.default_locale.code
    assert_equal SupportedLocales.base_english_name, SupportedLocales.default_english_name
    assert_equal SupportedLocales.base_native_name, SupportedLocales.default_native_name
  end

  def test_supported_locales_includes_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal ['en-US','es-ES', 'he-IL'], SupportedLocales.supported_locale_codes
    assert_equal ['en-US','es-ES', 'he-IL'], SupportedLocales.supported_locales.collect {|l| l.code}
    assert_equal ['en','es', 'he'], SupportedLocales.supported_language_codes
    assert SupportedLocales.supported?('en-US')
    assert SupportedLocales.supported?('en')
    assert SupportedLocales.supported?(Locale.new('en-US'))
    assert_equal ['English','Spanish','Hebrew'], SupportedLocales.supported_english_language_names
    assert_equal ['English','Español','עברית'], SupportedLocales.supported_native_language_names
  end

  def test_active_locales_defaults_to_supported_locales
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert_equal ['en-US','es-ES', 'he-IL'], SupportedLocales.active_locale_codes
    assert_equal ['en-US','es-ES', 'he-IL'], SupportedLocales.active_locales.collect {|l| l.code}
    assert_equal ['en','es', 'he'], SupportedLocales.active_language_codes
    assert SupportedLocales.active?('en-US')
    assert SupportedLocales.active?('en')
    assert SupportedLocales.active?(Locale.new('en-US'))
    assert_equal ['English','Spanish','Hebrew'], SupportedLocales.active_english_language_names
    assert_equal ['English','Español','עברית'], SupportedLocales.active_native_language_names
  end

  def test_non_base_locales_shouldnt_include_base_locale
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales)
    assert !SupportedLocales.non_base_locales.any? {|l| l.code == 'en-US'}
    assert ['es-ES', 'he-IL'], SupportedLocales.non_base_locale_codes
    assert ['es', 'he'], SupportedLocales.non_base_language_codes
    assert_equal ['Spanish','Hebrew'], SupportedLocales.non_base_english_language_names
    assert_equal ['Español','עברית'], SupportedLocales.non_base_native_language_names
    assert !SupportedLocales.non_base?('en-US')
    assert !SupportedLocales.non_base?('en')
    assert !SupportedLocales.non_base?(Locale.new('en-US'))
  end

  def test_non_base_locales_should_only_include_supported_locales
    SupportedLocales.clear
    SupportedLocales.define(@supported_locales,'en-US', ['es-ES'])
    assert !SupportedLocales.non_base_locales.any? {|l| l.code == 'en-US'}
    assert SupportedLocales.non_base_locales.any? {|l| l.code == 'he-IL'}
    assert ['es-ES','he-IL'], SupportedLocales.non_base_locale_codes
    assert ['es','he'], SupportedLocales.non_base_language_codes
    assert_equal ['Spanish','Hebrew'], SupportedLocales.non_base_english_language_names
    assert_equal ['Español','עברית'], SupportedLocales.non_base_native_language_names
    assert !SupportedLocales.non_base?('en-US')
    assert !SupportedLocales.non_base?('en')
    assert !SupportedLocales.non_base?(Locale.new('en-US'))
    assert SupportedLocales.non_base?('es-ES')
    assert SupportedLocales.non_base?('es')
    assert SupportedLocales.non_base?(Locale.new('es-ES'))
    assert SupportedLocales.non_base?('he-IL')
    assert SupportedLocales.non_base?('he')
    assert SupportedLocales.non_base?(Locale.new('he-IL'))
  end

  def test_default_locale_should_be_supported_and_active
    SupportedLocales.clear

    assert_nothing_raised do
      SupportedLocales.define(@supported_locales,'en-US', ['es-ES'], 'es-ES')
      assert_equal 'es', SupportedLocales.default_language_code
      assert_equal 'ES', SupportedLocales.default_locale.country.code
      assert_equal 'es-ES', SupportedLocales.default_locale_code
      assert_equal 'es-ES', SupportedLocales.default_locale.code
      assert_equal 'Spanish', SupportedLocales.default_english_name
      assert_equal 'Español', SupportedLocales.default_native_name
    end

    assert_raise RuntimeError do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en-US', ['es-ES'], 'he-IL')
    end

    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en-US', ['es-ES'], 'en-US')
    end
  end

  def test_active_locales_should_be_subset_of_supported_locales

    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
      assert SupportedLocales.active_locale_codes.all? {|l| SupportedLocales.supported_locale_codes.include?(l)}
      assert SupportedLocales.active_locales.all? {|l| SupportedLocales.supported_locales.include?(l)}
      assert SupportedLocales.active_language_codes.all? {|l| SupportedLocales.supported_language_codes.include?(l)}
      assert SupportedLocales.active_english_language_names.all? {|l| SupportedLocales.supported_english_language_names.include?(l)}
      assert SupportedLocales.active_native_language_names.all? {|l| SupportedLocales.supported_native_language_names.include?(l)}
    end

    assert_raise RuntimeError do
      SupportedLocales.clear
      SupportedLocales.define(@supported_locales,'en-US', ['pl-PL'])
    end
  end

  def test_inactive_locales_should_not_be_subset_of_active_locales
    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
      assert SupportedLocales.inactive_locale_codes.all? {|l| !SupportedLocales.active_locale_codes.include?(l)}
      assert SupportedLocales.inactive_locales.all? {|l| !SupportedLocales.active_locales.include?(l)}
      assert SupportedLocales.inactive_language_codes.all? {|l| !SupportedLocales.active_language_codes.include?(l)}
      assert SupportedLocales.inactive_english_language_names.all? {|l| !SupportedLocales.active_english_language_names.include?(l)}
      assert SupportedLocales.inactive_native_language_names.all? {|l| !SupportedLocales.active_native_language_names.include?(l)}
    end
  end

  def test_inactive_locales_should_be_subset_of_supported_locales
    assert_nothing_raised do
      SupportedLocales.clear
      SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
      assert SupportedLocales.inactive_locale_codes.all? {|l| SupportedLocales.supported_locale_codes.include?(l)}
      assert SupportedLocales.inactive_locales.all? {|l| SupportedLocales.supported_locales.include?(l)}
      assert SupportedLocales.inactive_language_codes.all? {|l| SupportedLocales.supported_language_codes.include?(l)}
      assert SupportedLocales.inactive_english_language_names.all? {|l| SupportedLocales.supported_english_language_names.include?(l)}
      assert SupportedLocales.inactive_native_language_names.all? {|l| SupportedLocales.supported_native_language_names.include?(l)}
    end
  end

  def test_supported_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
    assert_equal 'en-US', SupportedLocales['en-US'].code
    assert_equal 'en-US', SupportedLocales['en'].code
    assert_equal 'es-ES', SupportedLocales['es-ES'].code
    assert_equal 'es-ES', SupportedLocales['es'].code
    assert_equal 'he-IL', SupportedLocales['he-IL'].code
    assert_equal 'he-IL', SupportedLocales['he'].code
    assert_equal 'pl-PL', SupportedLocales['pl-PL'].code
    assert_equal 'pl-PL', SupportedLocales['pl'].code

    assert_nil SupportedLocales['fr']
    assert_nil SupportedLocales['fr-FR']
  end

  def test_active_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
    assert_equal 'en-US', ActiveLocales['en-US'].code
    assert_equal 'en-US', ActiveLocales['en'].code
    assert_equal 'es-ES', ActiveLocales['es-ES'].code
    assert_equal 'es-ES', ActiveLocales['es'].code
    assert_equal 'he-IL', ActiveLocales['he-IL'].code
    assert_equal 'he-IL', ActiveLocales['he'].code

    assert_nil ActiveLocales['pl-PL']
    assert_nil ActiveLocales['pl']
    assert_nil ActiveLocales['fr']
    assert_nil ActiveLocales['fr-FR']
  end

  def test_non_base_shortcut
    SupportedLocales.clear
    SupportedLocales.define(['es-ES','he-IL','pl-PL'],'en-US', ['es-ES','he-IL'])
    assert_equal 'es-ES', NonBaseLocales['es-ES'].code
    assert_equal 'es-ES', NonBaseLocales['es'].code
    assert_equal 'he-IL', NonBaseLocales['he-IL'].code
    assert_equal 'he-IL', NonBaseLocales['he'].code
    assert_equal 'pl-PL', NonBaseLocales['pl-PL'].code
    assert_equal 'pl-PL', NonBaseLocales['pl'].code

    assert_nil NonBaseLocales['en-US']
    assert_nil NonBaseLocales['en']
    assert_nil NonBaseLocales['fr']
    assert_nil NonBaseLocales['fr-FR']
  end
end