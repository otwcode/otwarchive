class AddMissionStatementToSeller < ActiveRecord::Migration
  def self.up
    add_column :sellers, :mission_statement, :string
  end

  def self.down
    remove_column :sellers, :mission_statement
  end
end
