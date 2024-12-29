class CreateLocaleLanguages < ActiveRecord::Migration[7.0]
  def change
    # Copies table structure over, data will be copied over in a rake task 
    ActiveRecord::Base.connection.execute("CREATE TABLE locale_languages LIKE languages;")

    # Update index names for locale_languages table
    remove_index :locale_languages, column: [:short], name: "index_languages_on_short"
    remove_index :locale_languages, column: [:sortable_name], name: "index_languages_on_sortable_name"

    change_table :locale_languages do |t|
      t.index :short
      t.index :sortable_name
    end
  end
end
