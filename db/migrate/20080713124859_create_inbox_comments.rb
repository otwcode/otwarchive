class CreateInboxComments < ActiveRecord::Migration
  def self.up
    create_table :inbox_comments do |t|
      t.references :user
      t.integer :feedback_comment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :inbox_comments
  end
end
