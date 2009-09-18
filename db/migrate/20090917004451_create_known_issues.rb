class CreateKnownIssues < ActiveRecord::Migration
  def self.up
    create_table :known_issues do |t|
      t.integer :admin_id
      t.string :title
      t.text :content
      t.datetime :updated_at
      t.datetime :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :known_issues
  end
end
