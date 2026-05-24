class AuditsCleanupJob < ApplicationJob
  QUERY_DELETE_LIMIT = 5_000
  JOB_DELETE_LIMIT = QUERY_DELETE_LIMIT * 10

  queue_as :utilities

  def self.perform(query_delete_limit: QUERY_DELETE_LIMIT, job_delete_limit: JOB_DELETE_LIMIT)
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

    query = query.limit(query_delete_limit)

    query_delete_count, job_delete_count = 0, 0

    loop do
      query_delete_count = query.delete_all
      break unless query_delete_count == query_delete_limit

      job_delete_count += query_delete_count
      break unless job_delete_count < job_delete_limit
    end
  end
end
