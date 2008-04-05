require File.dirname(__FILE__) + '/test_helper'

class ViewTranslationTest < Test::Unit::TestCase
  include Globalize

  fixtures :globalize_languages, :globalize_countries, :globalize_translations

  def setup
    Globalize::Locale.set("en-US")
    Globalize::Locale.set_base_language("en-US")
  end

  def test_translate
    assert_equal "This is the default", "This is the default".t
    Locale.set("he-IL")
    assert_equal "This is the default", "This is the default".t
    assert_equal "ועכשיו בעברית", "And now in Hebrew".t
  end

  def test_plural
    Locale.set("pl-PL")
    assert_equal "1 plik", "%d file" / 1
    assert_equal "2 pliki", "%d file" / 2
    assert_equal "3 pliki", "%d file" / 3
    assert_equal "4 pliki", "%d file" / 4

    assert_equal "5 plików", "%d file" / 5
    assert_equal "8 plików", "%d file" / 8
    assert_equal "13 plików", "%d file" / 13
    assert_equal "21 plików", "%d file" / 21

    assert_equal "22 pliki", "%d file" / 22
    assert_equal "23 pliki", "%d file" / 23
    assert_equal "24 pliki", "%d file" / 24

    assert_equal "25 plików", "%d file" / 25
    assert_equal "31 plików", "%d file" / 31
  end

  def test_aliases
    Locale.set("he-IL")
    assert_equal "ועכשיו בעברית", "And now in Hebrew".translate
    assert_equal "ועכשיו בעברית", _("And now in Hebrew")
  end

  def test_set_translation
    assert_equal "a dark and stormy night", "a dark and stormy night".t
    Locale.set_translation("a dark and stormy night", "quite a dark and stormy night")
    assert_equal "quite a dark and stormy night", "a dark and stormy night".t

    Locale.set("he-IL")
    assert_equal "a dark and stormy night", "a dark and stormy night".t
    Locale.set_translation("a dark and stormy night", "ליל קודר וגועש")
    assert_equal "ליל קודר וגועש", "a dark and stormy night".t
    polish = Language.pick("pl")

    Locale.set_translation("a dark and stormy night", polish, "How do you say this in Polish?")

    Locale.set("en-US")
    assert_equal "quite a dark and stormy night", "a dark and stormy night".t
    Locale.set("pl-PL")
    assert_equal "How do you say this in Polish?", "a dark and stormy night".t
  end

  def test_set_translation_pl
    Locale.set_translation("%d dark and stormy nights", "quite a dark and stormy night",
      "%d dark and stormy nights")
    assert_equal "quite a dark and stormy night", "%d dark and stormy nights".t
    assert_equal "5 dark and stormy nights", "%d dark and stormy nights" / 5

    Locale.set("he-IL")
    Locale.set_translation("%d dark and stormy nights",
      [ "ליל קודר וגועש", "%d לילות קודרים וגועשים" ])
    assert_equal "ליל קודר וגועש", "%d dark and stormy nights".t
    assert_equal "7 לילות קודרים וגועשים", "%d dark and stormy nights" / 7

    Locale.set("en-US")
    assert_equal "quite a dark and stormy night", "%d dark and stormy nights".t
  end

	def test_set_pluralized_translation
    Locale.set_pluralized_translation '%d dark and stormy nights', 
      1, 'quite a dark and stormy night'
    Locale.set_pluralized_translation '%d dark and stormy nights', 
      2, 'wow, %d dark and stormy nights'
    assert_equal "quite a dark and stormy night", "%d dark and stormy nights" / 1
    assert_equal "wow, 5 dark and stormy nights", "%d dark and stormy nights" / 5
	end
	
  def test_missed_report
    Locale.set("he-IL")
    assert_nil ViewTranslation.find(:first,
      :conditions => %q{language_id = 2 AND tr_key = 'not in database'})
    assert_equal "not in database", "not in database".t
    result = ViewTranslation.find(:first,
      :conditions => %q{language_id = 2 AND tr_key = 'not in database'})
    assert_not_nil result, "There should be a record in the db with nil text"
    assert_nil result.text
  end

  # for when language doesn't have a translation
  def test_default_number_substitution
    Locale.set("pl-PL")
    assert_equal "There are 0 translations for this",
      "There are %d translations for this" / 0
  end

  # for when language only has one pluralization form for translation
  def test_default_number_substitution2
    Locale.set("he-IL")
    assert_equal "יש לי 5 קבצים", "I have %d files" / 5
  end

  def test_symbol
    Locale.set("he-IL")
    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal "this is the default", :bogus_translation.t("this is the default")
  end

  def test_syntax_error
    Locale.set("ur")
    assert_raise(SyntaxError) { "I have %d bogus numbers" / 5 }
  end

  def test_illegal_code
    assert_raise(SecurityError) { Locale.set("ba") }
  end

  def test_overflow_code
    assert_raise(SecurityError) { Locale.set("tw") }
  end

  def test_string_substitute
    assert_equal "Welcome, Josh", "welcome, %s" / "Josh"
  end

  def test_zero_form
    Locale.set_translation("%d items in your cart",
      [ "One item in your cart", "%d items in your cart" ], "Your cart is empty")
    assert_equal "8 items in your cart", "%d items in your cart" / 8
    assert_equal "One item in your cart", "%d items in your cart" / 1
    assert_equal "Your cart is empty", "%d items in your cart" / 0
  end

  def test_zero_form_default
    Locale.set_translation("%d items in your cart",
      [ "One item in your cart", "%d items in your cart" ])
    assert_equal "8 items in your cart", "%d items in your cart" / 8
    assert_equal "One item in your cart", "%d items in your cart" / 1
    assert_equal "0 items in your cart", "%d items in your cart" / 0
  end

  def test_string_substitute_he
    Locale.set("he-IL")
    assert_equal "ברוכים הבאים, יהושע", "welcome, %s" / "יהושע"
  end

  def test_no_substitute
    assert_equal "Don't substitute any %s in %s",
      "Don't substitute any %s in %s".t
  end

  def test_cache
    Locale.set("he-IL")
    tr = Locale.translator
    tr.cache_reset
    assert_equal 0, tr.cache_size
    assert_equal 0, tr.cache_count
    assert_equal 0, tr.cache_total_hits
    assert_equal 0, tr.cache_total_queries

    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal 1, tr.cache_count
    assert_equal 42, tr.cache_size
    assert_equal 0, tr.cache_total_hits
    assert_equal 1, tr.cache_total_queries

    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal 1, tr.cache_count
    assert_equal 42, tr.cache_size
    assert_equal 1, tr.cache_total_hits
    assert_equal 2, tr.cache_total_queries

    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal 1, tr.cache_count
    assert_equal 42, tr.cache_size
    assert_equal 2, tr.cache_total_hits
    assert_equal 3, tr.cache_total_queries

    assert_equal "ועכשיו בעברית",
      tr.instance_eval {
        cache_fetch("And now in Hebrew", Locale.language,
        Locale.language.plural_index(nil))
      }

    # test for purging
    tr.max_cache_size = 41 / 1024  # in kb
    assert_equal "יש לי 5 קבצים", "I have %d files" / 5
    assert_equal 1, tr.cache_count
    assert_equal 38, tr.cache_size
    assert_equal 3, tr.cache_total_hits
    assert_equal 5, tr.cache_total_queries

    assert_equal "יש לי 5 קבצים", "I have %d files" / 5
    assert_equal 1, tr.cache_count
    assert_equal 38, tr.cache_size
    assert_equal 4, tr.cache_total_hits
    assert_equal 6, tr.cache_total_queries

    tr.max_cache_size = 100000 / 1024 # in bytes

    # test for two items in cache
    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal 2, tr.cache_count
    assert_equal 80, tr.cache_size
    assert_equal 4, tr.cache_total_hits
    assert_equal 7, tr.cache_total_queries

    tr.max_cache_size = 8192  # set it back to default
    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t
    assert_equal 2, tr.cache_count
    assert_equal 80, tr.cache_size
    assert_equal 5, tr.cache_total_hits
    assert_equal 8, tr.cache_total_queries

    # test for invalidation on set_translation
    Locale.set_translation(:And_now_in_Hebrew, "override")
    assert_equal 1, tr.cache_count
    assert_equal 21, tr.cache_size
    assert_equal 5, tr.cache_total_hits
    assert_equal 8, tr.cache_total_queries

    assert_equal "override", :And_now_in_Hebrew.t
    assert_equal 2, tr.cache_count
    assert_equal 46, tr.cache_size
    assert_equal 5, tr.cache_total_hits
    assert_equal 9, tr.cache_total_queries

    # set it back to what it was for other tests
    Locale.set_translation(:And_now_in_Hebrew, "ועכשיו בעברית")
    assert_equal "ועכשיו בעברית", :And_now_in_Hebrew.t

    # phew!
  end

end
