class DropApplications < ActiveRecord::Migration
  def self.up
    drop_table :applications
    remove_column :locales, :application_id
    remove_column :phrases, :application_id
  end

  def self.down
    create_table :applications do |t|
      t.string :name
      t.text :location

      t.timestamps
    end
    
    add_column :locales, :application_id, :integer
    add_column :phrases, :application_id, :integer
  end
end
