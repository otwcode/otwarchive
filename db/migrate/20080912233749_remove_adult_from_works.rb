class RemoveAdultFromWorks < ActiveRecord::Migration
  def self.up
    remove_column :works, :adult
  end

  def self.down
    add_column :works, :adult, :boolean, :default => 0
  end
end  
