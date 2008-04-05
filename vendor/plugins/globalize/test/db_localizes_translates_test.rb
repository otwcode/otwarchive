require File.dirname(__FILE__) + '/test_helper'

class LocalizesTranslatesTest < Test::Unit::TestCase
  Globalize::DbTranslate.keep_translations_in_model = true

  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries,
    :globalize_products, :globalize_manufacturers, :globalize_categories,
    :globalize_categories_products, :globalize_simples, :globalize_unlocalized_classes

  class Product < ActiveRecord::Base
    set_table_name "globalize_products"

    has_and_belongs_to_many :categories, :join_table => "globalize_categories_products"
    belongs_to :manufacturer, :foreign_key => 'manufacturer_id'

    translates :name, :description, :specs
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

  class UnlocalizedClass < ActiveRecord::Base
    set_table_name "globalize_unlocalized_classes"
  end

  def setup
    Globalize::Locale.set_base_language("en-US")
    Globalize::Locale.set("en-US")
  end

  def test_access_base_locale_column
    simp = Simple.find(1)
    simp.name = 'First'
    simp.save!
    assert_equal simp.name, simp._name

    Globalize::Locale.set 'es-ES'
    simp.name = 'Primer'
    simp.save!
    assert_equal "First", simp._name
    assert_equal "Primer", simp.name

    simp._name = 'Second'
    simp.save!

    assert_equal "Primer", simp.name
    assert_equal "Second", simp._name

    Globalize::Locale.set 'en-US'
    assert_equal simp.name, simp._name
  end

  def test_find_by_override
    Globalize::Locale.set("en-US")
    first_product  = Product.find_by_name('first')
    fourth_product = Product.find_by_name('eff')
    second_product = Product.find_by_description('This is a description of the second product')
    assert_equal second_product, Product.find_by_specs('these are the specs for the second product')


    Globalize::Locale.set("es-ES")
    assert_equal first_product, Product.find_by_name('primer')
    assert_equal fourth_product, Product.find_by_name('effes')
    assert_equal second_product, Product.find_by_description('Esta es una descripcion del segundo producto')
    assert_equal second_product, Product.find_by_specs('estas son las especificaciones del segundo producto')

    Globalize::Locale.set("he-IL")
    assert_equal fourth_product, Product.find_by_name('סארט')
  end

  def test_base_as_default_false
    prod = Product.create!(:code => 'test-base', :name => 'english test')
    assert_equal 'english test', prod.name

    Globalize::Locale.set("es-ES")
    assert_nil prod.name
    assert_nil prod.name_before_type_cast

    prod.name = "spanish test"
    prod.save!

    assert_equal 'spanish test', prod.name
    assert_equal 'spanish test', prod.name_before_type_cast

    # delete spanish version and test if it reverts to english base
    prod.name = nil
    prod.save!

    assert_nil prod.name
    assert_nil prod.name_before_type_cast

    assert !prod.translated?(:name)
    assert prod.name_is_base?

    prod.save!
    assert_nil prod.name

    #test access of base column
    assert_equal 'english test', prod._name
    assert_equal 'english test', prod._name_before_type_cast

    # change base and see if spanish gets updated
    Globalize::Locale.set("en-US")
    prod.name = "english test two"
    prod.save!
    assert_equal "english test two", prod.name
    assert_equal "english test two", prod.name_before_type_cast
    Globalize::Locale.set("es-ES")
    assert_nil prod.name
    assert_nil prod.name_before_type_cast
  end

  def test_base_as_default_true

    Product.class_eval %{
      self.keep_translations_in_model = true
      translates :name, :description, :specs, :base_as_default => true
    }

    prod = Product.create!(:code => 'test-base', :name => 'english test')
    assert_equal 'english test', prod.name
    assert_equal 'english test', prod.name_before_type_cast
    Globalize::Locale.set("es-ES")
    assert_equal 'english test', prod.name
    assert_equal 'english test', prod.name_before_type_cast
    prod.name = "spanish test"
    prod.save!
    assert_equal 'spanish test', prod.name
    assert_equal 'spanish test', prod.name_before_type_cast

    # delete spanish version and test if it reverts to english base
    prod.name = nil
    assert_equal 'english test', prod.name
    assert_equal 'english test', prod.name_before_type_cast
    prod.save!
    assert_equal 'english test', prod.name
    assert_equal 'english test', prod.name_before_type_cast

    #test access of base column
    assert_equal 'english test', prod._name
    assert_equal 'english test', prod._name_before_type_cast

    # change base and see if spanish gets updated
    Globalize::Locale.set("en-US")
    prod.name = "english test two"
    prod.save!
    assert_equal "english test two", prod.name
    assert_equal "english test two", prod.name_before_type_cast
    Globalize::Locale.set("es-ES")
    assert_equal "english test two", prod.name
    assert_equal "english test two", prod.name_before_type_cast

    Product.class_eval %{
      self.keep_translations_in_model = true
      translates :name, :description, :specs, :base_as_default => false
    }
  end

  def test_find_by_on_unlocalized_class
    seymour = UnlocalizedClass.find_by_name('Seymour')
    assert_equal 'Seymour', seymour.name

    Globalize::Locale.set 'es-ES'
    wellington = UnlocalizedClass.find_by_code('cat1')
    assert_equal 'Wellington', wellington.name
  end

  def test_simple
    simp = Simple.find(1)
    assert_equal "first", simp.name
    assert_equal "This is a description of the first simple", simp.description

    Globalize::Locale.set 'es-ES'
    assert_equal "primer", simp.name
    assert_equal "Esta es una descripcion del primer simple", simp.description
  end

  def test_simple_save
    simp = Simple.find(1)
    simp.name = '1st'
    simp.save!

    Globalize::Locale.set 'es-ES'
    simp.name = '1º'
    simp.save!
  end

  def test_simple_create
    simp = Simple.new
    simp.name = '1st'
    simp.save!

    Globalize::Locale.set 'es-ES'
    simp = Simple.new
    simp.name = '1º'
    simp.save!
  end

  def test_native_language
    es = Globalize::Language.pick("es")
    assert_equal "Español", es.native_name
  end

  def test_nil
    Globalize::Locale.set(nil)
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product", prod.specs
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
    Globalize::Locale.set("es-ES")
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "estas son las especificaciones del primer producto",
      prod.specs
    assert_equal "Esta es una descripcion del primer producto",
      prod.description
  end

  def test_habtm_translation
    Globalize::Locale.set("es-ES")
    cat = Category.find(1)
    prods = cat.products
    assert_equal 1, prods.length
    prod = prods.first
    assert_equal "first-product", prod.code
    assert_equal "estas son las especificaciones del primer producto",
      prod.specs
    assert_equal "Esta es una descripcion del primer producto",
      prod.description
  end

  # test has_many translation
  def test_has_many_translation
    Globalize::Locale.set("es-ES")
    mfr = Manufacturer.find(1)
    assert_equal 5, mfr.products.length
    prod = mfr.products.find(1)
    assert_equal "first-product", prod.code
    assert_equal "estas son las especificaciones del primer producto",
      prod.specs
    assert_equal "Esta es una descripcion del primer producto",
      prod.description
  end

  def test_belongs_to_translation
    Globalize::Locale.set("es-ES")
    prod = Product.find(1)
    mfr = prod.manufacturer
    assert_equal "first-mfr", mfr.code
    assert_equal "Reverendo",
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

  def test_include
    Globalize::Locale.set("es-ES")
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "first-mfr", prods.first.manufacturer.code
    assert_equal "Reverendo", prods.first.manufacturer.name
    assert_equal "Reverendo", prods.last.manufacturer.name

    Globalize::Locale.set("en-US")
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "first-mfr", prods.first.manufacturer.code
    assert_equal "Reverend", prods.first.manufacturer.name
    assert_equal "Reverend", prods.last.manufacturer.name
  end

  def test_order_en
    prods = Product.find(:all, :order => Product.localized_facet(:name)).select {|rec| rec.name}
    assert_equal 5, prods[0].id
    assert_equal 3, prods[1].id
    assert_equal 4, prods[2].id
  end

  def test_order_es
    Globalize::Locale.set("es-ES")
    prods = Product.find(:all, :order => Product.localized_facet(:name)).select {|rec| rec.name}
    assert_equal 3, prods[0].id
    assert_equal 4, prods[1].id
    assert_equal 5, prods[2].id
  end

  def test_base_translation_create
    prod = Product.create!(:code => 'test-base', :name => 'english test')
    prod.reload
    assert_equal 'english test', prod.name
    Globalize::Locale.set("es-ES")
    assert_nil prod.name
    prod.name = "spanish test"
    prod.save!
    prod.reload
    assert_equal 'spanish test', prod.name

    # delete spanish version and test if it reverts to english base
    prod.name = nil
    assert_nil prod.name
    prod.save!
    prod.reload
    assert_nil prod.name
    assert_equal 'english test', prod._name

    # change base and see if spanish gets updated
    Globalize::Locale.set("en-US")
    prod.reload
    prod.name = "english test two"
    prod.save!
    prod.reload
    assert_equal "english test two", prod.name
    Globalize::Locale.set("es-ES")
    prod.reload
    assert_nil prod.name
  end

  def test_native_name
    heb = Globalize::Language.pick('he')
    assert_equal 'Hebrew', heb.english_name
    assert_equal 'עברית', heb.native_name
    urdu = Globalize::Language.pick('ur')
    assert_equal 'Urdu', urdu.english_name
    assert_equal 'Urdu', urdu.native_name
  end

  def test_association_create
    manufacturer = Manufacturer.find(:first)
    manufacturer.products.create(:code => 'a-code',
                                 :name => 'english name',
                                 :description => 'english description',
                                 :specs => 'english specs')


    prod = manufacturer.products.find(:first, :conditions => ["#{Product.localized_facet(:name)} = ?", 'english name'])

    assert_equal 'english name', prod.name
    assert_equal 'english description', prod.description
    assert_equal 'english specs', prod.specs

    Globalize::Locale.set("es-ES")

    assert_nil prod.name
    assert_nil prod.description
    assert_nil prod.specs

    assert_equal 'english name', prod._name
    assert_equal 'english description', prod._description
    assert_equal 'english specs', prod._specs

    prod.name        = 'nombre castellano'
    prod.description = 'descripcion castellana'
    prod.specs       = 'especificaciones castellanas'
    prod.save!

    prod = manufacturer.products.find(:first, :conditions => ["#{Product.localized_facet(:name)} = ?", 'nombre castellano'])

    assert_equal 'nombre castellano',            prod.name
    assert_equal 'descripcion castellana'      , prod.description
    assert_equal 'especificaciones castellanas', prod.specs

    assert_equal 'english name',                 prod._name
    assert_equal 'english description',          prod._description
    assert_equal 'english specs',                prod._specs

    assert  prod.translated?(:name)
    assert  prod.translated?(:description)
    assert  prod.translated?(:specs)

    Globalize::Locale.set("en-US")
    assert_equal 'english name',                 prod.name
    assert_equal 'english description',          prod.description
    assert_equal 'english specs',                prod.specs

    assert  prod.translated?(:name, 'es-ES')
    assert  prod.translated?(:description, 'es-ES')
    assert  prod.translated?(:specs, 'es-ES')
  end

  def test_returned_base
    Product.class_eval %{
      self.keep_translations_in_model = true
      translates :name, :description, :specs, {
        :base_as_default => true,
        :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }
      }
    }

    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    assert_equal "first-product", prod.code
    assert_equal "these are the specs for the first product", prod.specs
    assert_equal "זהו תיאור המוצר הראשון", prod.description

    assert prod.specs_is_base?
    assert !prod.description_is_base?

    assert_equal 'ltr', prod.specs.direction
    assert_equal 'rtl', prod.description.direction
  end

  def test_bidi_embed
    Product.class_eval %{
      self.keep_translations_in_model = true
      translates :name, :description, :specs, {
        :base_as_default => true,
        :name => { :bidi_embed => false }, :specs => { :bidi_embed => false }
      }
    }

    Globalize::Locale.set("he-IL")
    prod = Product.find(2)
    assert_equal "\xe2\x80\xaaThis is a description of the second product\xe2\x80\xac",
      prod.description
  end
end
