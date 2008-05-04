class CreateReadings < ActiveRecord::Migration
  def self.up
    create_table :readings do |t|
      t.integer :major_version_read
      t.integer :minor_version_read
      t.references :user
      t.references :work

      t.timestamps
    end
  end

  def self.down
    drop_table :readings
  end
end
