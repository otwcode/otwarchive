class AddLastLoginTimeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :last_sign_in_at, :datetime
  end

  def self.down
    remove_column :users, :last_sign_in_at
  end
end
