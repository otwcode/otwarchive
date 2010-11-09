class CreateMissingWorkIndexes < ActiveRecord::Migration
  def self.up
    add_index "works", "restricted"
    add_index "works", "hidden_by_admin"
    add_index "works", "posted"
    add_index "works", "revised_at"
  end

  def self.down
    drop_index "works", "restricted"
    drop_index "works", "hidden_by_admin"
    drop_index "works", "posted"
    drop_index "works", "revised_at"
  end
end
