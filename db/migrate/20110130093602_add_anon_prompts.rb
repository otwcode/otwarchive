class AddAnonPrompts < ActiveRecord::Migration
  def self.up
    add_column :prompts, :anonymous, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :prompts, :anonymous
  end
end
