# Job to fill the user_past_usernames and user_past_emails tables using information from the audits table
class AuditsBackfillJob < RedisSetJob
  queue_as :utilities

  def self.base_key
    "audits_backfill"
  end

  def self.job_size
    1000
  end

  def self.batch_size
    100
  end

  def perform_on_batch(user_ids)
    # scans by users so audits can be taken from users and limited appropriately
    User.where(id: user_ids).find_each do |user|
      # gets past data audits within limits
      past_data = user.audits.order(id: :desc).where(action: "update").limit(ArchiveConfig.USER_HISTORIC_VALUES_LIMIT).filter_map do |audit|
        if audit.audited_changes.key?("login")
          { username: audit.audited_changes["login"].first, changed_at: audit.created_at }
        elsif audit.audited_changes.key?("email")
          { email: audit.audited_changes["email"].first, changed_at: audit.created_at }
        end
      end
      past_data = past_data.uniq{ |audit| audit[:username] }.reject { |audit| audit[:username] == user.login }
      past_data = past_data.uniq{ |audit| audit[:email] }.reject { |audit| audit[:email] == user.email }
      # adds each type of past data to the appropriate database table
      past_data.each do |audit|
        UserPastUsername.find_or_create_by!(user_id: user.id, username: audit[:username], changed_at: audit[:changed_at]) if audit.key?(:username)
        UserPastEmail.find_or_create_by!(user_id: user.id, email_address: audit[:email], changed_at: audit[:changed_at]) if audit.key?(:email)
      end
    end
  end
end
