class AddPinchRequestToChallengeAssignment < ActiveRecord::Migration
  def self.up
    add_column :challenge_assignments, :pinch_request_signup_id, :integer
  end

  def self.down
    remove_column :challenge_assignments, :pinch_request_signup_id
  end
end
