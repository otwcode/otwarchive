class AddKudoIndexes < ActiveRecord::Migration
  def self.up
    add_index "kudos", ["commentable_id", "commentable_type"]
    add_index "kudos", "pseud_id"
    add_index "kudos", "ip_address"
    add_index "works", "delta"
    add_index "tags", "type"
  end

  def self.down
    drop_index "kudos", ["commentable_id", "commentable_type"]
    drop_index "kudos", "pseud_id"
    drop_index "kudos", "ip_address"
    drop_index "works", "delta"
    drop_index "tags", "type"
  end
end
