require File.dirname(__FILE__) + '/test_helper'

class ViewTranslationNamespaceTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries, :globalize_translations

  def setup
    Globalize::Locale.set_base_language("en-US")
    Globalize::Locale.set("en-US")
  end

  def test_simple_translate_with_namespace
    Locale.set('en-US')
    assert_equal 'draw', 'draw'.t
    assert_equal 'draw', 'draw' >> 'lottery'

    Locale.set('es-ES')
    assert_equal 'dibujar', 'draw'.t
    assert_equal 'seleccionar', 'draw'.tn(:lottery)
    assert_equal 'seleccionar', 'draw' >> 'lottery'

    Locale.set('en-US')
    assert_equal 'draw', 'draw' >> 'lottery'
  end

  def test_plural_translate_with_namespace
    Locale.set('en-US')
    assert_equal 'draw once', 'draw %d times' / 1
    assert_equal 'draw 3 times', 'draw %d times' / 3
    assert_equal 'draw 1 times', 'draw %d times'.tn('lottery',1)
    assert_equal 'draw 3 times', 'draw %d times'.tn('lottery',3)

    Locale.set('es-ES')

    assert_equal 'dibujar una vez', 'draw %d times' / 1
    assert_equal 'dibujar 3 veces', 'draw %d times' / 3

    assert_equal 'seleccionar una vez', 'draw %d times' >> 'lottery'
    assert_equal 'seleccionar 3 veces', 'draw %d times'.tn('lottery',3)
  end

  def test_set_translation_with_namespace
    Locale.set('en-US')
    assert_equal 'bar', 'bar'.t
    Locale.set_translation('bar', 'bartop')
    assert_equal 'bartop', 'bar'.t
    assert_equal 'bar', 'bar' >> 'verbs'
    Locale.set_translation_with_namespace('bar', 'verbs', 'block')
    assert_equal 'block', 'bar' >> 'verbs'

    Locale.set('es-ES')
    assert_equal 'bar', 'bar'.t
    Locale.set_translation('bar', 'barra')
    assert_equal 'barra', 'bar'.t

    Locale.set_translation_with_namespace('bar', 'verbs', 'bloquear')
    assert_equal 'bloquear', 'bar' >> 'verbs'

    polish = Language.pick("pl")
    Locale.set_translation_with_namespace("bar",'verbs', polish, "bar (verb) in Polish?")
    Locale.set("pl-PL")
    assert_equal 'bar (verb) in Polish?', 'bar' >> 'verbs'
  end

  def test_set_plural_translations_with_namespace
    Locale.set('en-US')
    Locale.set_translation('play %d times', 'play once', 'play %d times')

    Locale.set('es-ES')
    Locale.set_translation('play %d times', 'jugar una vez', 'jugar %d veces')
    Locale.set_translation_with_namespace('play %d times', 'music', 'tocar una vez', 'tocar %d veces')

    Locale.set('es-ES')
    assert_equal 'jugar una vez', 'play %d times' / 1
    assert_equal 'jugar 3 veces', 'play %d times' / 3

    assert_equal 'tocar una vez', 'play %d times'.tn(:music,1)
    assert_equal 'tocar 3 veces', 'play %d times'.tn(:music,3)

    Locale.set('en-US')
    assert_equal 'play 1 times', 'play %d times'.tn(:music,1)
    assert_equal 'play 3 times', 'play %d times'.tn(:music,3)
  end

  def test_missed_report_with_namespace
    Locale.set("es-ES")
    assert_nil ViewTranslation.find(:first,
      :conditions => %q{language_id = 7 AND tr_key = 'still not in database' AND namespace = 'namespacing' })
    assert_equal "still not in database", "still not in database" >> 'namespacing'
    result = ViewTranslation.find(:first,
      :conditions => %q{language_id = 7 AND tr_key = 'still not in database' AND namespace = 'namespacing'})
    assert_not_nil result, "There should be a record in the db with nil text for this namespace"
    assert_nil result.text
  end

  def test_zero_form_with_namespace
    Locale.set("es-ES")
    Locale.set_translation_with_namespace("Play this %d times.",'music',
      [ "Tocalo una vez.", "Tocalo %d veces." ], "No lo tocas.")
    assert_equal "Tocalo 8 veces.", "Play this %d times.".tn(:music,8)
    assert_equal "Tocalo una vez.", "Play this %d times.".tn(:music,1)
    assert_equal "No lo tocas.", "Play this %d times.".tn(:music,0)
  end

end