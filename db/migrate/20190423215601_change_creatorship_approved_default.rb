class ChangeCreatorshipApprovedDefault < ActiveRecord::Migration[5.1]
  def change
    # Once all pre-existing records have had their approved value set to true,
    # we want to change the default to false.
    change_column_default :creatorships, :approved, from: true, to: false
  end
end
