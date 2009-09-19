class AddSuspendedUntilToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suspended_until, :datetime
  end

  def self.down
    remove_column :users, :suspended_until
  end
end
