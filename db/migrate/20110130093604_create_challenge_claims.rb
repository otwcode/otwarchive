class CreateChallengeClaims < ActiveRecord::Migration
  def self.up
    create_table :challenge_claims do |t|
      t.integer :collection_id
      t.integer :creation_id
      t.string :creation_type
      
      t.integer :request_signup_id
      t.integer :request_prompt_id
      t.integer :claiming_user_id
      t.datetime :sent_at
      t.datetime :fulfilled_at
      t.datetime :defaulted_at

      t.timestamps
    end
  end

  def self.down
    drop_table :challenge_claims
  end
end
