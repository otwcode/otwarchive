class AddLastWranglerToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :last_wrangler_id, :integer
    add_column :tags, :last_wrangler_type, :string
  end

  def self.down
    remove_column :tags, :last_wrangler_id
    remove_column :tags, :last_wrangler_type
  end
end
