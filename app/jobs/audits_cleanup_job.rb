class AuditsCleanupJob < ApplicationJob
  DELETE_LIMIT = 10_000

  queue_as :utilities

  def self.perform
    preserve_usernames = AdminSetting.current.preserve_audit_records_usernames&.split(/,\s*/) || []
    preserve_user_ids = User.where(login: preserve_usernames).select(:id).map(&:id)

    query = Audited.audit_class.where("0")

    if ArchiveConfig.USER_KEEP_AUDIT_UPDATES_DAYS > -1
      query = query.or(
        Audited.audit_class.where(
          auditable_type: "User",
          action: "update",
          created_at: ..ArchiveConfig.USER_KEEP_AUDIT_UPDATES_DAYS.days.ago
        ).and(
          Audited.audit_class.where.not(
            auditable_id: preserve_user_ids
          )
        )
      )
    end

    if ArchiveConfig.USER_KEEP_AUDIT_CREATES_DESTROYS_DAYS > -1
      query = query.or(
        Audited.audit_class.where(
          auditable_type: "User",
          action: %w[create destroy],
          created_at: ..ArchiveConfig.USER_KEEP_AUDIT_CREATES_DESTROYS_DAYS.days.ago
        ).and(
          Audited.audit_class.where.not(
            auditable_id: preserve_user_ids
          )
        )
      )
    end

    query.limit(DELETE_LIMIT).delete_all
  end
end
