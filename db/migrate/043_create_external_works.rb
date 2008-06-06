class CreateExternalWorks < ActiveRecord::Migration
  def self.up
    create_table :external_works do |t|
      t.string :url
      t.string :author
      t.boolean :dead

      t.timestamps
    end
  end

  def self.down
    drop_table :external_works
  end
end
