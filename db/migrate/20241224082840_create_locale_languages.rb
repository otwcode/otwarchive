class CreateLocaleLanguages < ActiveRecord::Migration[7.0]
  def change
    ActiveRecord::Base.connection.execute("CREATE TABLE locale_languages LIKE languages;")
  end
end
