class UpdateTagSetNominations < ActiveRecord::Migration
  def self.up
    execute "UPDATE tag_set_nominations, pseuds SET tag_set_nominations.pseud_id = pseuds.user_id WHERE tag_set_nominations.pseud_id = pseuds.id"
    rename_column("tag_set_nominations", "pseud_id","user_id")
  end

  def self.down

    execute "UPDATE tag_set_nominations, pseuds SET tag_set_nominations.user_id = pseuds.id WHERE tag_set_nominations.user_id = pseuds.user_id"
    rename_column("tag_set_nominations", "user_id","pseud_id")
  end
end