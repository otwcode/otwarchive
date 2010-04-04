class CreateChallengeAssignments < ActiveRecord::Migration
  def self.up
    create_table :challenge_assignments do |t|
      t.references :collection
      t.references :creation, :polymorphic => true
      t.integer :offer_signup_id
      t.integer :request_signup_id
      t.integer :pinch_hitter_id
      t.datetime :sent_at
      t.datetime :fulfilled_at
      t.datetime :defaulted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :challenge_assignments
  end
end
