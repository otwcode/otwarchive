class CreateCollectionProfiles < ActiveRecord::Migration
  def self.up
    create_table :collection_profiles do |t|
      t.references :collection
      t.text :intro
      t.text :faq
      t.text :rules

      t.timestamps
    end
  end

  def self.down
    drop_table :collection_profiles
  end
end
