class CreateCollections < ActiveRecord::Migration
  def self.up
    create_table :collections do |t|
      t.string :name
      t.string :title
      t.string :email
      t.string :header_image_url
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :collections
  end
end
