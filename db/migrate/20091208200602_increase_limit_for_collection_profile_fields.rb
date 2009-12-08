class IncreaseLimitForCollectionProfileFields < ActiveRecord::Migration
  def self.up
    change_column :collection_profiles, :intro, :text, :limit => 110000
    change_column :collection_profiles, :rules, :text, :limit => 110000
    change_column :collection_profiles, :faq, :text, :limit => 110000
  end

  def self.down
  end
end
