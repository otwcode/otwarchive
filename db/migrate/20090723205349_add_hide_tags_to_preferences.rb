class AddHideTagsToPreferences < ActiveRecord::Migration
  def self.up
   add_column :preferences, :hide_freeform, :boolean, :default => false, :null => false
  end
 		
  def self.down
    remove_column :preferences, :hide_freeform
  end
end
