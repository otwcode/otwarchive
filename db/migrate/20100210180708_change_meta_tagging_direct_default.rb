class ChangeMetaTaggingDirectDefault < ActiveRecord::Migration
  def self.up
    change_column :meta_taggings, :direct, :boolean, :default => true
  end

  def self.down
    change_column :meta_taggings, :direct, :boolean, :default => false
  end
end
