class CreateUserInviteRequests < ActiveRecord::Migration
  def self.up
    create_table :user_invite_requests do |t|
      t.references :user
      t.integer :quantity
      t.text :reason
      t.boolean :granted, :null => false, :default => false
      t.boolean :handled, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_invite_requests
  end
end
