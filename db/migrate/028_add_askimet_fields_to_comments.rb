class AddAskimetFieldsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :user_agent, :string
    add_column :comments, :approved, :boolean
    Comment.update_all("approved=1")
  end

  def self.down
    remove_column :comments, :user_agent
    remove_column :comments, :approved
  end
end
