class AddPreserveAuditRecordsUserIdsToAdminSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_settings, :preserve_audit_records_user_ids, :string
  end
end
