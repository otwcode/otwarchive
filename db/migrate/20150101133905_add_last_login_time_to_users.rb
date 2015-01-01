class AddLastLoginTimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_login_at, :datetime
  end

  def self.down
    remove_column :users, :last_login_at
  end
end
