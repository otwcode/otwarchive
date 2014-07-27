class CreateSearches < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.references :user
      t.string :name
      t.text :options
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :searches
  end
end
