namespace :i18n_db do
  desc 'Reset the translation data'
  task :reset => [ :teardown, :setup ]

  desc 'Create translation database tables'
  task :setup => [ :create_tables ]

  desc 'Remove all translation data'
  task :teardown => :drop_tables

  desc 'Create translation database tables'
  task :create_tables => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    ActiveRecord::Base.connection.create_table :i18n_db_translations, :force => true do |t|
      t.column :tr_key,                 :string
      t.column :locale_id,              :integer
      t.column :text,                   :text
      t.column :namespace,              :string
      t.column :created_at,             :datetime
      t.column :updated_at,             :datetime
    end
    ActiveRecord::Base.connection.add_index :i18n_db_translations, [ :tr_key, :locale_id ]
    
    #Doesn't work - index name too long - elz
    #ActiveRecord::Base.connection.add_index :i18n_db_translations, [ :tr_key, :locale_id, :updated_at ]

    ActiveRecord::Base.connection.create_table :i18n_db_locales, :force => true do |t|
      t.column :iso,                    :string
      t.column :short,                  :string
      t.column :name,                   :string
      t.column :main,                   :boolean
      t.column :updated_at,             :datetime
    end
    ActiveRecord::Base.connection.add_index :i18n_db_locales, :iso
    ActiveRecord::Base.connection.add_index :i18n_db_locales, :short
  end

  desc 'Drops translation database tables'
  task :drop_tables => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    ActiveRecord::Base.connection.drop_table :i18n_db_translations
    ActiveRecord::Base.connection.drop_table :i18n_db_locales
  end

  desc 'Purge locale data'
  task :purge_locale_data => :environment do
    I18nDb::Locale.destroy_all
    I18nDb::Translation.destroy_all
  end
end
