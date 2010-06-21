require 'test_helper'
require 'fileutils'

class TranslationTest < ActiveSupport::TestCase

  def setup
    Tolk::Locale.primary_locale(true)
  end

  test "translation is inavlid when a duplicate exists" do
    translation = Tolk::Translation.new :phrase => tolk_translations(:hello_world_da).phrase, :locale => tolk_translations(:hello_world_da).locale
    translation.text = "Revised Hello World"
    assert translation.invalid?
    assert translation.errors.on(:phrase_id)
  end
  
  test "translation is not changed when text is assigned an equal value in numberic form" do
    translation = tolk_translations(:human_format_precision_en)
    assert_equal "1", translation.text
    translation.text = "1"
    assert_equal false, translation.changed?
    translation.text = 1
    assert_equal false, translation.changed?
  end

  test "translation with string value" do
    assert_equal "Hello World", tolk_translations(:hello_world_en).value
  end

  test "translation with string value with variables" do
    text = "{{attribute}} {{message}}"
    assert_equal text, Tolk::Translation.new(:text => text).value
  end

  test "translation with numeric value" do
    assert_equal 1, tolk_translations(:human_format_precision_en).value
  end
  
  test "translation with hash value" do
    hash = {:foo => "bar"}
    assert_equal hash, Tolk::Translation.new(:text => hash).value
  end
end