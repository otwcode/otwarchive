class UpdateTagSetOwnerships < ActiveRecord::Migration
  def self.up
    execute "UPDATE tag_set_ownerships, pseuds SET tag_set_ownerships.pseud_id = pseuds.user_id WHERE tag_set_ownerships.pseud_id = pseuds.id"
    rename_column("tag_set_ownerships", "pseud_id","user_id")
  end

  def self.down
    execute "UPDATE tag_set_ownerships, pseuds SET tag_set_ownerships.user_id = pseuds.id WHERE tag_set_ownerships.user_id = pseuds.user_id"
    rename_column("tag_set_ownerships", "user_id","pseud_id")
  end
end