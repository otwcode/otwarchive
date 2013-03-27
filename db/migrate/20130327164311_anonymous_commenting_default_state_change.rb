class AnonymousCommentingDefaultStateChange < ActiveRecord::Migration
  def self.up
    remove_column :works, :anon_commenting_enabled
    add_column :works, :anon_commenting_disabled, :boolean, :null => false, :default => false
  end

  def self.down
    add_column :works, :anon_commenting_enabled, :boolean, :null => true, :default => true
    remove_column :works, :anon_commenting_disabled
  end
end
