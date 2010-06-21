require 'test_helper'
require 'fileutils'

class SyncTest < ActiveSupport::TestCase
  def setup
    Tolk::Locale.delete_all
    Tolk::Translation.delete_all
    Tolk::Phrase.delete_all

    Tolk::Locale.locales_config_path = File.join(Rails.root, "test/locales/sync/")

    I18n.backend.reload!
    I18n.load_path = [Tolk::Locale.locales_config_path + 'en.yml']
    I18n.backend.send :init_translations

    Tolk::Locale.primary_locale(true)
  end

  def test_flat_hash
    data = {'home' => {'hello' => 'hola', 'sidebar' => {'title' => 'something'}}}
    result = Tolk::Locale.send(:flat_hash, data)

    assert_equal 2, result.keys.size
    assert_equal ['home.hello', 'home.sidebar.title'], result.keys.sort
    assert_equal ['hola', 'something'], result.values.sort
  end

  def test_sync_sets_previous_text_for_primary_locale
    Tolk::Locale.sync!

    # Change 'Hello World' to 'Hello Super World'
    Tolk::Locale.expects(:load_translations).returns({"hello_world" => "Hello Super World"})
    Tolk::Locale.sync!

    translation = Tolk::Locale.primary_locale(true).translations.first
    assert_equal 'Hello Super World', translation.text
    assert_equal 'Hello World', translation.previous_text
  end

  def test_sync_sets_primary_updated_for_secondary_translations_on_update
    spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!

    phrase1 = Tolk::Phrase.all.detect {|p| p.key == 'hello_world'}
    t1 = spanish.translations.create!(:text => 'hola', :phrase => phrase1)
    phrase2 = Tolk::Phrase.all.detect {|p| p.key == 'nested.hello_country'}
    t2 = spanish.translations.create!(:text => 'nested hola', :phrase => phrase2)

    # Change 'Hello World' to 'Hello Super World'. But don't change nested.hello_country
    Tolk::Locale.expects(:load_translations).returns({'hello_world' => 'Hello Super World', 'nested.hello_country' => 'Nested Hello Country'})
    Tolk::Locale.sync!

    t1.reload
    t2.reload

    assert t1.primary_updated?
    assert ! t2.primary_updated?
  end
  
  def test_sync_marks_translations_for_review_when_the_primary_translation_has_changed
    Tolk::Locale.create!(:name => 'es')
    
    phrase = Tolk::Phrase.create! :key => 'number.precision'
    english_translation = phrase.translations.create!(:text => "1", :locale => Tolk::Locale.find_by_name("en"))
    spanish_translation = phrase.translations.create!(:text => "1", :locale => Tolk::Locale.find_by_name("es"))

    Tolk::Locale.expects(:load_translations).returns({'number.precision' => "1"})
    Tolk::Locale.sync! and spanish_translation.reload
    assert spanish_translation.up_to_date?

    Tolk::Locale.expects(:load_translations).returns({'number.precision' => "2"})
    Tolk::Locale.sync! and spanish_translation.reload
    assert spanish_translation.out_of_date?
    
    spanish_translation.text = "2"
    spanish_translation.save! and spanish_translation.reload
    assert spanish_translation.up_to_date?

    Tolk::Locale.expects(:load_translations).returns({'number.precision' => 2})
    Tolk::Locale.sync! and spanish_translation.reload
    assert spanish_translation.up_to_date?

    Tolk::Locale.expects(:load_translations).returns({'number.precision' => 1})
    Tolk::Locale.sync! and spanish_translation.reload
    assert spanish_translation.out_of_date?
  end

  def test_sync_creates_locale_phrases_translations
    Tolk::Locale.sync!

    # Created by sync!
    primary_locale = Tolk::Locale.find_by_name!(Tolk::Locale.primary_locale_name)

    assert_equal ["Hello World", "Nested Hello Country"], primary_locale.translations.map(&:text).sort
    assert_equal ["hello_world", "nested.hello_country"], Tolk::Phrase.all.map(&:key).sort
  end

  def test_sync_deletes_stale_translations_for_secondary_locales_on_delete_all
    spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!

    phrase = Tolk::Phrase.all.detect {|p| p.key == 'hello_world'}
    hola = spanish.translations.create!(:text => 'hola', :phrase => phrase)

    # Mimic deleting all the translations
    Tolk::Locale.expects(:load_translations).returns({})
    Tolk::Locale.sync!

    assert_equal 0, Tolk::Phrase.count
    assert_equal 0, Tolk::Translation.count

    assert_raises(ActiveRecord::RecordNotFound) { hola.reload }
  end

  def test_sync_deletes_stale_translations_for_secondary_locales_on_delete_some
    spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!

    phrase = Tolk::Phrase.all.detect {|p| p.key == 'hello_world'}
    hola = spanish.translations.create!(:text => 'hola', :phrase => phrase)

    # Mimic deleting 'hello_world'
    Tolk::Locale.expects(:load_translations).returns({'nested.hello_country' => 'Nested Hello World'})
    Tolk::Locale.sync!

    assert_equal 1, Tolk::Phrase.count
    assert_equal 1, Tolk::Translation.count
    assert_equal 0, spanish.translations.count

    assert_raises(ActiveRecord::RecordNotFound) { hola.reload }
  end

  def test_sync_handles_deleted_keys_and_updated_translations
    Tolk::Locale.sync!

    # Mimic deleting 'nested.hello_country' and updating 'hello_world'
    Tolk::Locale.expects(:load_translations).returns({"hello_world" => "Hello Super World"})
    Tolk::Locale.sync!

    primary_locale = Tolk::Locale.find_by_name!(Tolk::Locale.primary_locale_name)

    assert_equal ['Hello Super World'], primary_locale.translations.map(&:text)
    assert_equal ['hello_world'], Tolk::Phrase.all.map(&:key).sort
  end

  def test_sync_doesnt_mess_with_existing_translations
    spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!

    phrase = Tolk::Phrase.all.detect {|p| p.key == 'hello_world'}
    hola = spanish.translations.create!(:text => 'hola', :phrase => phrase)

    # Mimic deleting 'nested.hello_country' and updating 'hello_world'
    Tolk::Locale.expects(:load_translations).returns({"hello_world" => "Hello Super World"})
    Tolk::Locale.sync!

    hola.reload
    assert_equal 'hola', hola.text
  end

  def test_sync_array_values
    spanish = Tolk::Locale.create!(:name => 'es')

    data = {"weekend" => ['Friday', 'Saturday', 'Sunday']}
    Tolk::Locale.expects(:load_translations).returns(data)
    Tolk::Locale.sync!

    assert_equal 1, Tolk::Locale.primary_locale.translations.count

    translation = Tolk::Locale.primary_locale.translations.first
    assert_equal data['weekend'], translation.text

    yaml = ['Saturday', 'Sunday'].to_yaml
    spanish_weekends = spanish.translations.create!(:text => yaml, :phrase => Tolk::Phrase.first)
    assert_equal YAML.load(yaml), spanish_weekends.text
  end

  def test_dump_all_after_sync
    spanish = Tolk::Locale.create!(:name => 'es')

    Tolk::Locale.sync!

    phrase = Tolk::Phrase.all.detect {|p| p.key == 'hello_world'}
    hola = spanish.translations.create!(:text => 'hola', :phrase => phrase)

    tmpdir = File.join Rails.root, "tmp/sync/locales"
    FileUtils.mkdir_p(tmpdir)
    Tolk::Locale.dump_all(tmpdir)

    spanish_file = "#{tmpdir}/es.yml"
    data = YAML::load(IO.read(spanish_file))['es']
    assert_equal ['hello_world'], data.keys
    assert_equal 'hola', data['hello_world']
  ensure
    FileUtils.rm_f(tmpdir)
  end
end