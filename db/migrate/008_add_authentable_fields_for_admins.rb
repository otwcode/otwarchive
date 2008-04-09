class AddAuthentableFieldsForAdmins < ActiveRecord::Migration
  def self.up
    Admin.add_admin_fields
  end

  def self.down
    Admin.remove_admin_fields
  end
end