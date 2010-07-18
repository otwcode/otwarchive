class CreateSkins < ActiveRecord::Migration
  def self.up
    create_table :skins do |t|
      t.string 'title'
      t.integer 'author_id'
      t.text 'css'
      t.boolean 'public', :default => 0

      t.timestamps
    end

    add_column :preferences, :skin_id, :integer

  end

  def self.down
    drop_table :skins
    remove_column :preferences, :skin_id
  end
end
