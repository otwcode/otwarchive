ActiveRecord::Schema.define do

  create_table :globalize_simples, :force => true do |t|
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
  end

  create_table :globalize_products, :force => true do |t|
    t.column :code, :string
    t.column :manufacturer_id, :integer
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
    t.column :description, :string
    t.column :description_es, :string
    t.column :description_he, :string
    t.column :specs, :string
    t.column :specs_es, :string
    t.column :specs_he, :string
  end

  add_index :globalize_products, :code, :unique => true
  add_index :globalize_products, :manufacturer_id

  create_table :globalize_manufacturers, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
  end

  add_index :globalize_manufacturers, :code, :unique

  create_table :globalize_categories, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
    t.column :name_es, :string
    t.column :name_he, :string
  end

  add_index :globalize_categories, :code, :unique

  create_table :globalize_categories_products, :id => false, :force => true do |t|
    t.column :category_id, :integer
    t.column :product_id, :integer
  end

  add_index :globalize_categories_products, :category_id
  add_index :globalize_categories_products, :product_id

  create_table :globalize_countries, :force => true do |t|
    t.column :code,               :string, :limit => 2
    t.column :english_name,       :string
    t.column :date_format,        :string
    t.column :currency_format,    :string
    t.column :currency_code,      :string, :limit => 3
    t.column :thousands_sep,      :string, :limit => 1
    t.column :decimal_sep,        :string, :limit => 1
    t.column :currency_decimal_sep,        :string, :limit => 1
    t.column :number_grouping_scheme,      :string
  end
  add_index :globalize_countries, :code

  create_table :globalize_translations, :force => true do |t|
    t.column :type,                   :string
    t.column :tr_key,                 :string
    t.column :table_name,             :string
    t.column :item_id,                :integer
    t.column :facet,                  :string
    t.column :built_in,               :boolean, :default => true
    t.column :language_id,            :integer
    t.column :pluralization_index,    :integer
    t.column :text,                   :text
    t.column :namespace,              :string
  end

  add_index :globalize_translations, [ :tr_key, :language_id ], :name => 'tr_key'
  add_index :globalize_translations, [ :table_name, :item_id, :language_id ], :name => 'table_name'

  create_table :globalize_languages, :force => true do |t|
    t.column :iso_639_1, :string, :limit => 2
    t.column :iso_639_2, :string, :limit => 3
    t.column :iso_639_3, :string, :limit => 3
    t.column :rfc_3066,  :string
    t.column :english_name, :string
    t.column :english_name_locale, :string
    t.column :english_name_modifier, :string
    t.column :native_name, :string
    t.column :native_name_locale, :string
    t.column :native_name_modifier, :string
    t.column :macro_language, :boolean
    t.column :direction, :string
    t.column :pluralization, :string
    t.column :scope, :string, :limit => 1
  end

  add_index :globalize_languages, :iso_639_1
  add_index :globalize_languages, :iso_639_2
  add_index :globalize_languages, :iso_639_3
  add_index :globalize_languages, :rfc_3066

  create_table :globalize_unlocalized_classes, :force => true do |t|
    t.column :code, :string
    t.column :name, :string
  end

  add_index :globalize_unlocalized_classes, :code, :unique
end