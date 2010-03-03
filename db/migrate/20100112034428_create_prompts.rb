class CreatePrompts < ActiveRecord::Migration
  def self.up
    create_table :prompts do |t|
      t.references :collection
      t.references :challenge_signup
      t.references :pseud
      t.references :tag_set
      t.integer :optional_tag_set_id

      t.string :title
      t.string :url
      t.text :description
      t.boolean :offer
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :prompts
  end
end
