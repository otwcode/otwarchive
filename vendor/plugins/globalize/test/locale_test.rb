require File.dirname(__FILE__) + '/test_helper'

class LocaleTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries

  def setup
  end

  def test_rfc
    rfc = RFC_3066.parse 'en-US'
    assert_equal 'en', rfc.language
    assert_equal 'US', rfc.country
    assert_equal 'en-US', rfc.locale
  end

  def test_new
    loc = Locale.new('en-US')
    assert_equal 'en', loc.language.code
    assert_equal 'US', loc.country.code
  end

  def test_base
  end

end
