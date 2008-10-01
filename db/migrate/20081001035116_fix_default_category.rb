class FixDefaultCategory < ActiveRecord::Migration
  def self.up
    # change display name of default to Tags
    TagCategory::DEFAULT.display_name = "Tags"
    TagCategory::DEFAULT.save
  end

  def self.down
  end
end
