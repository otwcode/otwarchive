class AddExternalAuthorBackToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :external_author_id, :integer
  end

  def self.down
    remove_column :invitations, :external_author_id
  end
end
