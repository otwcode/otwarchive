class AddLastViewedToReading < ActiveRecord::Migration
  #this moves updated_at from an automatic timestamp to
  #one which can be backdated
  def self.up
    rename_column :readings, :updated_at, :last_viewed
  end

  def self.down
    rename_column :readings, :last_viewed, :updated_at
  end
end
