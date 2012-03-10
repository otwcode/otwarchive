class AddFailedLoginCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :failed_login_count, :integer
  end

  def self.down
    remove_column :users, :failed_login_count
  end
end
