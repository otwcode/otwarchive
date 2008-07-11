class CreateSerialWorks < ActiveRecord::Migration
  def self.up
    create_table :serial_works do |t|
      t.references :series
      t.references :work
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :serial_works
  end
end
