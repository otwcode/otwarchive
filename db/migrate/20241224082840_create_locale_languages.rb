class CreateLocaleLanguages < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.execute("CREATE TABLE locale_languages LIKE languages;")

    ActiveRecord::Base.connection.execute("INSERT INTO locale_languages SELECT * FROM languages;")

    # Only if you care about the name of the index being consistent 
    # remove_index :locale_languages, column: [:short], name: "index_languages_on_short"
    # remove_index :locale_languages, column: [:sortable_name], name: "index_languages_on_sortable_name"

    # change_table :locale_languages do |t|
    #   t.index :short
    #   t.index :sortable_name
    # end
  end
end
