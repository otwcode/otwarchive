class AddLanguageToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :language_id, :integer
    
    execute "UPDATE works SET language_id=1819 WHERE language_id IS NULL"
  end

  def self.down
    remove_column :works, :language_id
  end
end
