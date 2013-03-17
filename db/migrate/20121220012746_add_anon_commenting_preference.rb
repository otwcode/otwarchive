class AddAnonCommentingPreference < ActiveRecord::Migration
  def self.up
    add_column :works, :anon_commenting_enabled, :boolean, :null => true, :default => true
  end

  def self.down
    remove_column :works, :anon_commenting_enabled
  end
end
