class CreatePreferences < ActiveRecord::Migration
  def self.up
    create_table :preferences do |t|
      t.references :user
      t.boolean :history_enabled
      t.boolean :email_visible

      t.timestamps
    end
  end

  def self.down
    drop_table :preferences
  end
end
