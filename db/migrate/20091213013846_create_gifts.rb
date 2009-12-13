class CreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts do |t|
      t.references :work
      t.string :recipient_name

      t.timestamps
    end
  end

  def self.down
    drop_table :gifts
  end
end
