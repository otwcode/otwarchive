class RemovePinchRequestSignupFromChallengeAssignments < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_column :challenge_assignments, :pinch_request_signup_id, :integer
  end
end