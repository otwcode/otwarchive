class AddPlainSkinToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :plain_text_skin, :boolean, :default => false, :null => false
  end
 		
  def self.down
    remove_column :preferences, :plain_text_skin
  end
end
