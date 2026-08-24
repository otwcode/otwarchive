# Collects the GDPR/support data associated with an email address: guest
# activity, plus account history through indexed lookups (a LIKE scan on
# audits is too expensive, see AO3-6015 / PR #4997).
#
# Deleted accounts only survive in audits; deep_search: true opts into a
# chunked scan of that table.
class EmailDataReport
  include Rails.application.routes.url_helpers

  # Bounds each deep-search query to a primary-key range.
  AUDIT_SCAN_BATCH_SIZE = 1_000_000

  def initialize(email, deep_search: false)
    @email = email.to_s.strip.downcase
    @deep_search = deep_search
  end

  def to_s
    parts = ["Data for #{@email}"]
    parts << previous_usernames_section
    parts << previous_emails_section
    parts << ip_addresses_section
    parts << user_agents_section
    parts << next_of_kin_section
    parts << comments_section
    parts << abuse_reports_section
    parts << support_tickets_section
    "#{parts.compact.join("\n\n")}\n"
  end

  def default_url_options
    { host: ArchiveConfig.APP_URL }
  end

  private

  def abuse_reports
    @abuse_reports ||= AbuseReport.where(email: @email).to_a
  end

  def comments
    @comments ||= Comment.where(email: @email).to_a
  end

  def support_tickets
    @support_tickets ||= Feedback.where(email: @email).to_a
  end

  def next_of_kin_for
    @next_of_kin_for ||= User.where(id: FannishNextOfKin.where(kin_email: @email).select(:user_id)).pluck(:login)
  end

  def user_ids
    @user_ids ||= begin
      ids = User.where(email: @email).or(User.where(unconfirmed_email: @email)).pluck(:id)
      ids |= UserPastEmail.where(email_address: @email).pluck(:user_id)
      ids |= deleted_user_ids if @deep_search
      ids
    end
  end

  # LIKE matches substrings, so candidates are verified against the exact
  # email before being included.
  def deleted_user_ids
    max_id = Audited::Audit.maximum(:id)
    return [] if max_id.nil?

    ids = []
    (Audited::Audit.minimum(:id)..max_id).step(AUDIT_SCAN_BATCH_SIZE) do |start|
      candidates = Audited::Audit.where(auditable_type: "User")
        .where(id: start...(start + AUDIT_SCAN_BATCH_SIZE))
        .where("audited_changes LIKE ?", "%#{Audited::Audit.sanitize_sql_like(@email)}%")
        .pluck(:auditable_id, :audited_changes)
      ids.concat(candidates.filter_map { |id, changes| id if email_in_changes?(changes) })
    end
    ids.uniq
  end

  def email_in_changes?(changes)
    return false unless changes.is_a?(Hash)

    changes.values_at("email", "unconfirmed_email").any? do |value|
      value == @email || (value.is_a?(Array) && value.include?(@email))
    end
  end

  def audit_history
    @audit_history ||= begin
      previous_usernames = []
      previous_emails = []
      ips = []

      # Abuse reports do not persist user_agent; support tickets do not
      # persist ip_address.
      ips.concat(abuse_reports.filter_map { |report| report.ip_address.presence })
      ips.concat(comments.filter_map { |comment| comment.ip_address.presence })

      # Audits of admin actions are excluded to avoid revealing admins' IPs.
      # Unlike get_user_data.rb, destroy is included for deleted accounts.
      audits = Audited::Audit.where(auditable_type: "User", auditable_id: user_ids)
        .pluck(:action, :audited_changes, :remote_address, :user_type)
      audits.each do |action, changes, ip, actor_type|
        # Admin-made changes record the admin's IP, not the user's.
        ip = nil if actor_type == "Admin"
        # Created or deleted account
        if %w[create destroy].include?(action)
          ips << ip if ip.present?
          # The destroy audit is the only place a deleted account's login
          # and email survive.
          if action == "destroy" && changes.is_a?(Hash)
            previous_usernames << changes["login"] if changes["login"].present?
            previous_emails << changes["email"] if changes["email"].present? && changes["email"] != @email
          end
        # Other account changes
        elsif action == "update"
          next unless changes.respond_to?(:each)

          changes.each do |k, v|
            # Keep the branches separate for the per-key comments.
            # rubocop:disable Lint/DuplicateBranch
            case k
            when "accepted_tos_version"
              ips << ip if ip.present?
            # Changed email address
            when "email"
              ips << ip if ip.present?
              previous_emails << v[0] if v.is_a?(Array) && v[0].present?
            # Changed password, post-Devise
            when "encrypted_password"
              ips << ip if ip.present?
            # Failed login attempt, post-Devise
            # This is currently only recorded after a password reset or after the
            # account is locked and unlocked
            when "failed_attempts"
              ips << ip if ip.present?
            # Failed login attempt, pre-Devise
            when "failed_login_count"
              ips << ip if ip.present?
            # Failed login attempt that resulted in account being locked, post-Devise
            when "locked_at"
              ips << ip if ip.present?
            # Changed username
            when "login"
              ips << ip if ip.present?
              previous_usernames << v[0] if v.is_a?(Array) && v[0].present?
            # Requested password reset email, pre-Devise
            when "recently_reset"
              ips << ip if ip.present?
            # Submitted login form with "Remember me" checked, post-Devise
            # This is recorded whether the login attempt was successful or not
            when "remember_created_at"
              ips << ip if ip.present?
            # Requested password reset email, post-Devise
            when "reset_password_sent_at"
              ips << ip if ip.present?
            # Logged in, post-Devise
            when "sign_in_count"
              ips << ip if ip.present?
            end
            # rubocop:enable Lint/DuplicateBranch
          end
        end
      end

      {
        previous_usernames: previous_usernames.uniq,
        previous_emails: previous_emails.uniq,
        ips: ips.uniq
      }
    end
  end

  def user_agents
    agents = []
    agents.concat(comments.filter_map { |comment| comment.user_agent.presence })
    agents.concat(support_tickets.filter_map { |ticket| ticket.user_agent.presence })
    agents.uniq
  end

  def previous_usernames_section
    names = audit_history[:previous_usernames]
    return if names.empty?

    "Previous Usernames: #{names.to_sentence}"
  end

  def previous_emails_section
    emails = audit_history[:previous_emails]
    return if emails.empty?

    "Previous Email Addresses: #{emails.to_sentence}"
  end

  def ip_addresses_section
    ips = audit_history[:ips]
    return if ips.empty?

    ["IP Addresses:", *ips.map { |ip| "  #{ip}" }].join("\n")
  end

  def user_agents_section
    return if user_agents.empty?

    ["User Agents:", *user_agents.map { |user_agent| "  #{user_agent}" }].join("\n")
  end

  def next_of_kin_section
    return if next_of_kin_for.empty?

    "Fannish Next of Kin For: #{next_of_kin_for.to_sentence}"
  end

  def comments_section
    return if comments.empty?

    urls = comments.map { |comment| comment_url(comment) }
    ["Comments Left: ", *urls.map { |url| "  #{url}" }].join("\n")
  end

  def abuse_reports_section
    return if abuse_reports.empty?

    records_section("Abuse Reports:", abuse_reports)
  end

  def support_tickets_section
    return if support_tickets.empty?

    records_section("Support Tickets:", support_tickets)
  end

  def records_section(header, records)
    entries = records.map do |record|
      <<~ENTRY.strip
        From: #{record.username}
        Summary: #{record.summary}
        Content:
          #{record.comment}
      ENTRY
    end
    [header, *entries].join("\n\n")
  end
end
