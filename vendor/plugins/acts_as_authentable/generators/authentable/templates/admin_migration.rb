class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    <%= class_name %>.add_admin_fields
  end

  def self.down
    <%= class_name %>.remove_admin_fields
  end
end