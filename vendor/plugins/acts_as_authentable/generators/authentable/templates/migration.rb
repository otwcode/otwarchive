class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    <%= class_name %>.add_authentable_fields
  end

  def self.down
    <%= class_name %>.remove_authentable_fields
  end
end
