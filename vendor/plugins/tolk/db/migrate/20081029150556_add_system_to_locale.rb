class AddSystemToLocale < ActiveRecord::Migration
  def self.up
    add_column :locales, :system_id, :integer
  end

  def self.down
    remove_column :locales, :system
  end
end
