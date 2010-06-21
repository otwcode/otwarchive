require 'test_helper'

class LocaleTest < ActiveSupport::TestCase
  test "turning locale without nested phrases into a hash" do
    assert_equal({ "se" => { "hello_world" => "Hejsan Verdon" } }, tolk_locales(:se).to_hash)
  end

  test "turning locale with nested phrases into a hash" do
    assert_equal({ "en" => { 
      "number"=>{"human"=>{"format"=>{"precision"=>1}}},
      "hello_world" => "Hello World", 
      "nested" => { 
        "hello_world" => "Nested Hello World",
        "hello_country" => "Nested Hello Country"
      }
    }}, tolk_locales(:en).to_hash)
  end

  test "phrases without translations" do
    assert tolk_locales(:en).phrases_without_translation.include?(tolk_phrases(:cozy))
  end

  test "searching phrases without translations" do
    # assert tolk_locales(:en).search_phrases_without_translation("cozy").include?(tolk_phrases(:cozy))
    assert !tolk_locales(:en).search_phrases_without_translation("cozy").include?(tolk_phrases(:hello_world))
  end

  test "paginating phrases without translations" do
    Tolk::Phrase.per_page = 2
    locale = tolk_locales(:se)

    page1 = locale.phrases_without_translation
    assert_equal [4, 3], page1.map(&:id)

    page2 = locale.phrases_without_translation(2)
    assert_equal [2, 5], page2.map(&:id)

    page3 = locale.phrases_without_translation(3)
    assert page3.blank?
  end

  test "paginating phrases with translations" do
    Tolk::Phrase.per_page = 4
    locale = tolk_locales(:en)

    page1 = locale.phrases_with_translation
    assert_equal [1, 3, 2, 5], page1.map(&:id)

    page2 = locale.phrases_with_translation(2)
    assert page2.blank?
  end

  test "counting missing translations" do
    assert_equal 2, tolk_locales(:da).count_phrases_without_translation
    assert_equal 4, tolk_locales(:se).count_phrases_without_translation
  end

  test "dumping all locales to yml" do
    Tolk::Locale.primary_locale_name = 'en'
    Tolk::Locale.primary_locale(true)

    begin
      FileUtils.mkdir_p(File.join(Rails.root, "tmp/locales"))
      Tolk::Locale.dump_all(File.join(Rails.root, "tmp/locales"))

      %w( da se ).each do |locale|
        assert_equal \
          File.read(File.join(Rails.root, "test/locales/basic/#{locale}.yml")),
          File.read(File.join(Rails.root, "tmp/locales/#{locale}.yml"))
      end

      # Make sure dump doesn't generate en.yml
      assert ! File.exists?(File.join(Rails.root, "tmp/locales/en.yml"))
    ensure
      FileUtils.rm_rf(File.join(Rails.root, "tmp/locales"))
    end
  end

  test "human language name" do
    assert_equal 'English', tolk_locales(:en).language_name
    assert_equal 'pirate', Tolk::Locale.new(:name => 'pirate').language_name
  end
end