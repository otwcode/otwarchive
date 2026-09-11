class CreateLocaleLanguages < ActiveRecord::Migration[7.0]
  def up
    ActiveRecord::Base.connection.execute("CREATE TABLE locale_languages LIKE languages")
    ActiveRecord::Base.connection.execute("INSERT INTO locale_languages SELECT * FROM languages")

    rename_index :locale_languages, "index_languages_on_name", "index_locale_languages_on_name"
    rename_index :locale_languages, "index_languages_on_short", "index_locale_languages_on_short"
    rename_index :locale_languages, "index_languages_on_sortable_name", "index_locale_languages_on_sortable_name"
  end

  def down
    drop_table :locale_languages
  end
end
