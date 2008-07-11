class CreateCommunities < ActiveRecord::Migration
  def self.up
    create_table :communities do |t|
      t.string :name
      t.text :description
      t.boolean :open_membership

      t.timestamps
    end
  end

  def self.down
    drop_table :communities
  end
end
