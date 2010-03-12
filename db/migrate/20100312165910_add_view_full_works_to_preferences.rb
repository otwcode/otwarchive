class AddViewFullWorksToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :view_full_works, :boolean, :default => false, :null => false
  end
 		
  def self.down
    remove_column :preferences, :view_full_works
  end
end
