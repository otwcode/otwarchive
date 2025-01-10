#!script/rails runner
# usage:
# rails r script/get_email_data.rb

require "yaml"

include Rails.application.routes.url_helpers

# Base URL
default_url_options[:host] = ArchiveConfig.APP_URL

# Prompt for the email
print "Enter email: "
email = gets.chomp.downcase

# Abuse reports from email
abuse_reports = AbuseReport.where(email: email).to_a

# URLs of all comments
comments = Comment.where(email: email).to_a
comment_urls = comments.pluck(:id)&.map { |id| comment_url(id) }

# Support tickets from email
support_tickets = Feedback.where(email: email).to_a

# Names of people listing email as their FNOK
next_of_kin_for = FannishNextOfKin.where(kin_email: email).pluck(:user_id)&.map do |id|
  User.find(id).login
end

# List of IP addresses
# We handle IPs from the audits table below
ips = []
abuse_reports.pluck(:ip_address)&.each { |ip| ips << ip if ip.present? }
comments.pluck(:ip_address)&.each { |ip| ips << ip if ip.present? }
support_tickets.pluck(:ip_address)&.each { |ip| ips << ip if ip.present? }

# List of user agents
user_agents = []
abuse_reports.pluck(:user_agent)&.each { |ua| user_agents << ua if ua.present? }
comments.pluck(:user_agent)&.each { |ua| user_agents << ua if ua.present? }
support_tickets.pluck(:user_agent)&.each { |ua| user_agents << ua if ua.present? }

previous_usernames = []
previous_emails = []

# First we need to find any audits where the audited_changes include the
# provided email address.
# Then we need to get the auditable_id of those audits, which will tell us the
# user_id of any accounts previously belonging to this user.
# Then we need to get all the audits for those auditable_ids and collect the
# IPs, emails, and usernames from those.
# We have to do it this way because not all the relevant audits will contain
# the email address -- the audits with the email address are only a subset of
# the audits we need.
previous_user_ids = ActiveRecord::Base.connection
  .exec_query("SELECT DISTINCT(auditable_id) FROM audits WHERE audited_changes LIKE '%#{email}%'")
  .map { |row| row["auditable_id"] }
audits = ActiveRecord::Base.connection.exec_query("SELECT * FROM audits WHERE auditable_id IN (#{previous_user_ids.join(',')})") if previous_user_ids.present?
audits&.rows&.each do |audit|
  action = audit[8]
  changes = YAML.safe_load(audit[9],
                           permitted_classes: Rails.application.config.active_record.yaml_column_permitted_classes,
                           aliases: true)
  ip = audit[12]
  # Created or deleted account
  if %w[create destroy].include?(action)
    ips << ip if ip.present?
  elsif action == "update"
    changes.each do |k, v|
      # Silence rubocop, we want the separate branches for documentation purposes.
      # rubocop:disable Lint/DuplicateBranch
      case k
      when "accepted_tos_version"
        ips << ip if ip.present?
      # Changed email address
      when "email"
        ips << ip if ip.present?
        previous_emails << v[0] if v[0].present?
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
        previous_usernames << v[0] if v[0].present?
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

puts "Data for #{email}"
unless previous_usernames.empty?
  puts
  puts "Previous Usernames: #{previous_usernames.uniq.to_sentence}"
end
unless previous_emails.empty?
  puts
  puts "Previous Email Addresses: #{previous_emails.uniq.to_sentence}"
end
unless ips.empty?
  puts
  puts "IP Addresses:"
  ips.uniq.each do |ip|
    puts "  #{ip}"
  end
end
unless user_agents.empty?
  puts
  puts "User Agents:"
  user_agents.uniq.each do |user_agent|
    puts "  #{user_agent}"
  end
end
unless next_of_kin_for.empty?
  puts
  puts "Fannish Next of Kin For: #{next_of_kin_for.to_sentence}" unless next_of_kin_for.empty?
end
unless comment_urls.empty?
  puts
  puts "Comments Left: "
  comment_urls.map do |url|
    puts "  #{url}"
  end
end
unless abuse_reports.empty?
  puts
  abuse_reports.each do |report|
    puts "From: #{report.username}"
    puts "Summary: #{report.summary}"
    puts "Content: "
    puts "  #{report.comment}"
  end
end
unless support_tickets.empty?
  puts
  support_tickets.each do |ticket|
    puts "From: #{ticket.username}"
    puts "Summary: #{ticket.summary}"
    puts "Content: "
    puts "  #{ticket.comment}"
  end
end
