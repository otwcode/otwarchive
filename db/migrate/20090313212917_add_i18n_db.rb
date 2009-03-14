class AddI18nDb < ActiveRecord::Migration
  def self.up
    create_table :translations, :force => true do |t|
      t.column :tr_key,                 :string
      t.column :locale_id,              :integer
      t.column :text,                   :text
      t.column :namespace,              :string
      t.column :created_at,             :datetime
      t.column :updated_at,             :datetime
    end
    add_index :translations, [ :tr_key, :locale_id ]
    add_index :translations, [ :tr_key, :locale_id, :updated_at ]

    create_table :locales, :force => true do |t|
      t.column :iso,                    :string
      t.column :short,                  :string
      t.column :name,                   :string
      t.column :main,                   :boolean
      t.column :updated_at,             :datetime
    end
    add_index :locales, :iso
    add_index :locales, :short
    
    Locale.set_base_locale
    Work.update_all(["language_id = (?)", Locale.find_main_cached.id])
  end

  def self.down
  end
end
