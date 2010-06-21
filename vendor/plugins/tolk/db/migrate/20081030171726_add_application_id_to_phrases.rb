class AddApplicationIdToPhrases < ActiveRecord::Migration
  def self.up
    add_column :phrases, :application_id, :integer
  end

  def self.down
    remove_column :phrases, :application_id
  end
end
