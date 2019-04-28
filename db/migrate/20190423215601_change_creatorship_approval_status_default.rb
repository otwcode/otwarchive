class ChangeCreatorshipApprovalStatusDefault < ActiveRecord::Migration[5.1]
  def change
    # Once all pre-existing records have had their approved value set to
    # Approved, we want to change the default to Pending.
    change_column_default :creatorships, :approval_status, from: 1, to: 0
  end
end
