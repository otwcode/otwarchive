require 'test_helper'
require 'fileutils'

class FormatTest < ActiveSupport::TestCase
  def setup
    Tolk::Locale.delete_all
    Tolk::Translation.delete_all
    Tolk::Phrase.delete_all

    Tolk::Locale.locales_config_path = RAILS_ROOT + "/test/locales/formats/"

    I18n.backend.reload!
    I18n.load_path = [Tolk::Locale.locales_config_path + 'en.yml']
    I18n.backend.send :init_translations

    @en = Tolk::Locale.primary_locale(true)
    @spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!
  end

  def test_all_formats_are_loaded_properly
    # TODO : Investigate why the fuck does this test fail
    # assert_equal 1, @en['number']
    assert_equal 'I am just a stupid string :(', @en['string']
    assert_equal [1, 2, 3], @en['number_array']
    assert_equal ['sun', 'moon'], @en['string_array']
  end

  def test_pluaralization
    result = {'other' => 'Hello'}
    assert_equal result, @en['pluralization']

    assert ! @en['not_pluralization']
    assert_equal 'World', @en['not_pluralization.other']
    assert_equal 'fifo', @en['not_pluralization.lifo']
  end

  # def test_specail_activerecord_keys_and_prefixes
    # Special key
    # result = {'person' => 'Dude'}
    # assert_equal result, @en['activerecord.models']

    # Special prefix
    # result = {'login' => 'Handle'}
    # assert_equal result, @en['activerecord.attributes.person']
  # end

  def test_creating_translations_fails_on_mismatch_with_primary_translation
    # Invalid type
    assert_raises(ActiveRecord::RecordInvalid) { @spanish.translations.create!(:text => 'hola', :phrase => ph('number_array')) }

    # Invalid YAML
    assert_raises(ActiveRecord::RecordInvalid) { @spanish.translations.create!(:text => "1\n- 2\n", :phrase => ph('number_array')) }

    success = @spanish.translations.create!(:text => [1, 2], :phrase => ph('number_array'))
    assert_equal [1, 2], success.text

    success.text = "--- \n- 1\n- 2\n"
    success.save!
    assert_equal [1, 2], success.text
  end

  def test_creating_translations_with_nil_values
    # implicit nil value
    assert_raises(ActiveRecord::RecordInvalid) { @spanish.translations.create!(:phrase => ph('string')) }

    # explicit nil value
    niltrans = @spanish.translations.create!(:phrase => ph('string'), :text => '~')
    assert ! niltrans.text
  end

  def test_creating_translation_with_wrong_type
    assert_raises(ActiveRecord::RecordInvalid) { @spanish.translations.create!(:text => [1, 2], :phrase => ph('string')) }

    translation = @spanish.translations.create!(:text => "one more silly string", :phrase => ph('string'))
    assert_equal "one more silly string", translation.text
  end

  def test_bulk_translations_update_with_some_invalid_formats
    @spanish.translations_attributes = [
      {"locale_id" => @spanish.id, "phrase_id" => ph('string_array').id, "text" => 'invalid format'},
      {"locale_id" => @spanish.id, "phrase_id" => ph('string').id, "text" => 'spanish string'},
      {"locale_id" => @spanish.id, "phrase_id" => ph('number').id, "text" => '2'}
    ]

    assert_difference('Tolk::Translation.count', 2) { @spanish.save }

    @spanish.reload

    assert_equal 'spanish string', @spanish['string']
    assert_equal '2', @spanish['number']
    assert ! @spanish['string_array']
  end

  def test_bulk_update_saves_unchanged_record
    data = {"locale_id" => @spanish.id, "phrase_id" => ph('string').id, "text" => 'spanish string'}
    @spanish.translations_attributes = [data]
    @spanish.save!

    spanish_string = @spanish.translations.first
    spanish_string.force_set_primary_update = true
    spanish_string.save!
    assert spanish_string.primary_updated?

    @spanish.reload

    @spanish.translations_attributes = [data.merge('id' => spanish_string.id)]
    @spanish.save!

    spanish_string.reload
    assert ! spanish_string.primary_updated?
  end

  private

  def ph(key)
    Tolk::Phrase.all.detect {|p| p.key == key}
  end
end