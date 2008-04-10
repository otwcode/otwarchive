class CreatePseuds < ActiveRecord::Migration
  def self.up
    create_table :pseuds do |t|
      t.references :user
      t.string :name
      t.text :description
      t.boolean :is_default

      t.timestamps
    end
  end

  def self.down
    drop_table :pseuds
  end
end
