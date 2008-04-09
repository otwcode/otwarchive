class AddAuthentableFields < ActiveRecord::Migration
  def self.up
    Person.add_authentable_fields
  end

  def self.down
    Person.remove_authentable_fields
  end
end
