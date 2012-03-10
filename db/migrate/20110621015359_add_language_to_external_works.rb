class AddLanguageToExternalWorks < ActiveRecord::Migration
  def self.up
    add_column :external_works, :language_id, :integer
  end

  def self.down
    remove_column :external_works, :language_id
  end
end
