class RemovePinchRequestSignupFromChallengeAssignments < ActiveRecord::Migration[7.1]
  def change
    remove_column :challenge_assignments, :pinch_request_signup_id, :integer
  end
end
