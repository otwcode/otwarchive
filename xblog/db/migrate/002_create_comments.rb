class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :post
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
