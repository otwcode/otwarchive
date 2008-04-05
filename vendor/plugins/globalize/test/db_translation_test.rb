require File.dirname(__FILE__) + '/test_helper'

class TranslationTest < Test::Unit::TestCase
  Globalize::DbTranslate.keep_translations_in_model = false

  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries,
    :globalize_products, :globalize_manufacturers, :globalize_categories,
    :globalize_categories_products, :globalize_simples

  class Product < ActiveRecord::Base
    set_table_name "globalize_products"

    has_and_belongs_to_many :categories, :join_table => "globalize_categories_products"
    belongs_to :manufacturer, :foreign_key => 'manufacturer_id'

    translates :name, :description, :specs, {
      :name => { :bidi_embed => false }, :specs => { :bidi_embed => false } }
  end

  class Category < ActiveRecord::Base
    set_table_name "globalize_categories"
    has_and_belongs_to_many :products, :join_table => "globalize_categories_products"

    translates :name
  end

  class Manufacturer < ActiveRecord::Base
    set_table_name "globalize_manufacturers"
    has_many :products

    translates :name
  end

  class Simple < ActiveRecord::Base
    set_table_name "globalize_simples"

    translates :name, :description
  end

  def setup
    Globalize::Locale.set_base_language("en-US")
    Globalize::Locale.set("en-US")
  end

  def test_simple
    simp = Simple.find(1)
    assert_equal "first", simp.name
    assert_equal "This is a description of the first simple", simp.description

    Globalize::Locale.set 'he-IL'
    simp = Simple.find(1)
    assert_equal "זהו השם הראשון", simp.name
    assert_equal "זהו התיאור הראשון", simp.description
  end

  def test_simple_save
    simp = Simple.find(1)
    simp.name = '1st'
    simp.save!

    Globalize::Locale.set 'he-IL'
    simp = Simple.find(1)
    simp.name = 'ה-1'
    simp.save!
  end

  def test_simple_create
    simp = Simple.new
    simp.name = '1st'
    simp.save!

    Globalize::Locale.set 'he-IL'
    simp = Simple.new
    simp.name = 'ה-1'
    simp.save!
  end

  def test_native_language
    heb = Globalize::Language.pick("he")
    assert_equal "עברית", heb.native_name
  end

  def test_nil
    Globalize::Locale.set(nil)
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
  end

  def test_nil_include_translated
    Globalize::Locale.set(nil)

    prods = Product.find(:all, :order => "globalize_products.code", :include_translated => :manufacturer)
    assert_equal "first-product", prods[1].code
    assert_equal "these are the specs for the first product",
      prods[1].specs
    assert_equal "first", prods[1].name
    assert_equal "Reverend", prods.first.manufacturer_name
    assert_equal "Reverend", prods.last.manufacturer_name
  end

  def test_prod_tr_all
    prods = Product.find(:all, :order => "code" )
    assert_equal 5, prods.length
    assert_equal "first-product", prods[1].code
    assert_equal "second-product", prods[3].code
    assert_equal "these are the specs for the first product",
      prods[1].specs
    assert_equal "This is a description of the first product",
      prods[1].description
    assert_equal "these are the specs for the second product",
      prods[3].specs
  end

  def test_prod_tr_first
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "This is a description of the first product",
      prod.description
  end

  def test_prod_tr_id
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "This is a description of the first product",
      prod.description
  end

  # Ordering of records returned is database-dependent although MySQL is explicit about ordering
  # its result sets. This means this test is only guaranteed to pass on MySQL.
  def pending_test_prod_tr_ids
    prods = Product.find(1, 2)
    assert_equal 2, prods.length
    assert_equal "first-product", prods[0].code
    assert_equal "second-product", prods[1].code
    assert_equal "these are the specs for the first product",
      prods[0].specs
    assert_equal "This is a description of the first product",
      prods[0].description
    assert_equal "these are the specs for the second product",
      prods[1].specs
  end

  def test_base
    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  def test_habtm_translation
    Globalize::Locale.set("he-IL")
    cat = Category.find(1)
    prods = cat.products
    assert_equal 1, prods.length
    prod = prods.first
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  # test has_many translation
  def test_has_many_translation
    Globalize::Locale.set("he-IL")
    mfr = Manufacturer.find(1)
    assert_equal 5, mfr.products.length
    prod = mfr.products.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description
  end

  def test_belongs_to_translation
    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    mfr = prod.manufacturer
    assert_equal "first-mfr", mfr.code
    assert_equal "רברנד",
      mfr.name
  end

  def test_new
    prod = Product.new(:code => "new-product", :specs => "These are the product specs")
    assert_equal "These are the product specs", prod.specs
    assert_nil prod.description
  end

  # test creating updating
  def test_create_update
    prod = Product.create(:code => "new-product",
      :specs => "These are the product specs")
    assert prod.errors.empty?, prod.errors.full_messages.first
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "These are the product specs", prod.specs

    prod.specs = "Dummy"
    prod.save
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "Dummy", prod.specs
  end

  def test_include_translated
    Globalize::Locale.set("he-IL")
    prods = Product.find(:all, :include_translated => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "רברנד", prods.first.manufacturer_name
    assert_equal "רברנד", prods.last.manufacturer_name

    Globalize::Locale.set("en-US")
    prods = Product.find(:all, :include_translated => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "Reverend", prods.first.manufacturer_name
    assert_equal "Reverend", prods.last.manufacturer_name
  end

  # Doesn't pull in translations
  def test_include
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "first-mfr", prods.first.manufacturer.code
  end

  def test_order_en
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 5, prods[0].id
    assert_equal 3, prods[1].id
    assert_equal 4, prods[2].id
  end

  def test_order_he
    Globalize::Locale.set("he-IL")
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 4, prods[1].id
    assert_equal 5, prods[2].id
    assert_equal 3, prods[3].id
  end

  def test_base_translation_create
    prod = Product.create!(:code => 'test-base', :name => 'english test')
    prod.reload
    assert_equal 'english test', prod.name
    Globalize::Locale.set("he-IL")
    prod = Product.find_by_code('test-base')
    assert_equal 'english test', prod.name
    prod.name = "hebrew test"
    prod.save!
    prod.reload
    assert_equal 'hebrew test', prod.name

    # delete hebrew version and test if it reverts to english base
    prod.name = nil
    assert_nil prod.name
    prod.save!
    prod.reload
    assert_equal 'english test', prod.name

    # change base and see if hebrew gets updated
    Globalize::Locale.set("en-US")
    prod.reload
    prod.name = "english test two"
    prod.save!
    prod.reload
    assert_equal "english test two", prod.name
    Globalize::Locale.set("he-IL")
    prod.reload
    assert_equal "english test two", prod.name
  end

  def test_wrong_language
    prod = Product.find(1)

    Globalize::Locale.set("he-IL")
    assert_raise(Globalize::WrongLanguageError) { prod.description }
    assert_raise(Globalize::WrongLanguageError) { prod.description = "זהו תיאור המוצר השני" }
    assert_raise(Globalize::WrongLanguageError) { prod.save! }
    prod = Product.find(1)
    assert_equal "זהו תיאור המוצר הראשון", prod.description

    Globalize::Locale.set("en-US")
    assert_raise(Globalize::WrongLanguageError) { prod.description }
    assert_raise(Globalize::WrongLanguageError) { prod.save! }
  end

  def test_destroy
    prod = Product.find(1)
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    prod.destroy
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

  def test_destroy_class_method
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    Product.destroy(1)
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

# Function is removed, Globalite work fine without.
#  def test_fix_conditions
#    assert_equal 'globalize_products.name="test"',
#      Product.class_eval { fix_conditions('name="test"') }
#    assert_equal '(globalize_products.name="test" OR globalize_products.name = "test2")',
#      Product.class_eval { fix_conditions('(name="test" OR name = "test2")') }
#    assert_equal 'globalize_products.name = globalize_translations.name',
#      Product.class_eval { fix_conditions('globalize_products.name = globalize_translations.name') }
#    assert_equal ' globalize_products.name = globalize_translations.name',
#      Product.class_eval { fix_conditions(' name = globalize_translations.name') }
#    assert_equal ' globalize_products."name" = globalize_translations.name',
#      Product.class_eval { fix_conditions(' "name" = globalize_translations.name') }
#    assert_equal ' globalize_products.\'name\' = globalize_translations.name',
#      Product.class_eval { fix_conditions(' \'name\' = globalize_translations.name') }
#    assert_equal ' globalize_products.`name` = globalize_translations.name',
#      Product.class_eval { fix_conditions(' `name` = globalize_translations.name') }
#  end

  def test_native_name
    heb = Globalize::Language.pick('he')
    assert_equal 'Hebrew', heb.english_name
    assert_equal 'עברית', heb.native_name
    urdu = Globalize::Language.pick('ur')
    assert_equal 'Urdu', urdu.english_name
    assert_equal 'Urdu', urdu.native_name
  end

  def test_returned_base
    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product",
      prod.specs
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description

    assert prod.specs_is_base?
    assert !prod.description_is_base?

    assert_equal 'ltr', prod.specs.direction
    assert_equal 'rtl', prod.description.direction
  end

  def test_bidi_embed
    Globalize::Locale.set("he-IL")
    prod = Product.find(2)
    assert_equal "\xe2\x80\xaaThis is a description of the second product\xe2\x80\xac",
      prod.description
  end
  
  # association building/creating?
end
