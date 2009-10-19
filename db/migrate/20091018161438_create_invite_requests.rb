class CreateInviteRequests < ActiveRecord::Migration
  def self.up
    create_table :invite_requests do |t|
      t.string :email
      t.integer :position

      t.timestamps
    end
  end

  def self.down
    drop_table :invite_requests
  end
end
