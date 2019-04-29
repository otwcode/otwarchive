class AddApprovalStatusToCreatorships < ActiveRecord::Migration[5.1]
  def change
    # We set the default to 1 here because we want all pre-existing records
    # to count as Approved.
    add_column :creatorships, :approval_status, :integer,
      null: false, default: 1, limit: 1
  end
end
