class AddAuthentableFieldsForUsers < ActiveRecord::Migration
  def self.up
    User.add_authentable_fields
  end

  def self.down
    User.remove_authentable_fields
  end
end
