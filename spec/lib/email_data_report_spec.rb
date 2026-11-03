require "spec_helper"

describe EmailDataReport do
  subject { described_class.new(email).to_s }

  let(:email) { "guest@example.com" }

  it "prints only the header and the audits query when no data is found" do
    expect(subject).to start_with("Data for #{email}\n\nDeleted accounts")
    expect(subject).not_to include("IP Addresses:")
    expect(subject).not_to include("Comments Left:")
  end

  it "downcases the email before lookup" do
    create(:abuse_report, email: email, username: "Reporter", summary: "Spam", comment: "This is spam.")

    expect(described_class.new("Guest@Example.com").to_s).to include("From: Reporter")
  end

  describe "guest activity" do
    it "includes comment URLs, IPs, and user agents" do
      comment = create(
        :comment,
        :by_guest,
        :on_work_with_guest_comments_on,
        email: email,
        ip_address: "203.0.113.10",
        user_agent: "Lynx/2.8"
      )

      expect(subject).to include("Comments Left:")
      expect(subject).to include("/comments/#{comment.id}")
      expect(subject).to include("203.0.113.10")
      expect(subject).to include("Lynx/2.8")
    end

    it "includes abuse report header, name, summary, content, and IP" do
      create(
        :abuse_report,
        email: email,
        username: "ConcernedFan",
        summary: "Harassment",
        comment: "Please look at this.",
        ip_address: "203.0.113.20"
      )

      expect(subject).to include("Abuse Reports:")
      expect(subject).to include("From: ConcernedFan")
      expect(subject).to include("Summary: Harassment")
      expect(subject).to include("Please look at this.")
      expect(subject).to include("203.0.113.20")
    end

    it "includes support ticket header, name, summary, content, and user agent" do
      create(
        :feedback,
        email: email,
        username: "HelpfulGuest",
        summary: "Cannot log in",
        comment: "The login form errors.",
        user_agent: "Mozilla/5.0"
      )

      expect(subject).to include("Support Tickets:")
      expect(subject).to include("From: HelpfulGuest")
      expect(subject).to include("Summary: Cannot log in")
      expect(subject).to include("The login form errors.")
      expect(subject).to include("Mozilla/5.0")
    end

    it "lists users for whom the email is fannish next of kin" do
      user = create(:user, login: "fnok_lister")
      create(:fannish_next_of_kin, user: user, kin_email: email)

      expect(subject).to include("Fannish Next of Kin For: fnok_lister")
    end
  end

  describe "account history" do
    let(:user) { create(:user, email: "current@example.com") }

    before do
      user.past_emails.create!(email_address: email, changed_at: Time.current)
      user.audits.create!(
        action: "update",
        auditable: user,
        audited_changes: { "login" => ["old_guest_login", user.login] },
        remote_address: "198.51.100.5"
      )
      user.audits.create!(
        action: "update",
        auditable: user,
        audited_changes: { "email" => ["prior@example.com", user.email] },
        remote_address: "198.51.100.6"
      )
      user.audits.create!(
        action: "destroy",
        auditable: user,
        audited_changes: { "login" => user.login, "email" => user.email },
        remote_address: "198.51.100.7"
      )
    end

    it "queries audits by auditable_id, not by audited_changes LIKE" do
      queries = []
      callback = ->(_name, _start, _finish, _id, payload) { queries << payload[:sql] }

      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        subject
      end

      audit_queries = queries.grep(/FROM [`"]?audits[`"]?/i)
      expect(audit_queries).to be_present
      expect(audit_queries).to all(match(/auditable_id/i))
      expect(audit_queries).not_to include(a_string_matching(/audited_changes LIKE/i))
    end

    it "includes previous usernames, emails, and create/update/destroy IPs" do
      expect(subject).to include("Previous Usernames: old_guest_login")
      expect(subject).to include("Previous Email Addresses: prior@example.com")
      expect(subject).to include("198.51.100.5")
      expect(subject).to include("198.51.100.6")
      expect(subject).to include("198.51.100.7")
    end

    it "excludes the IP when an admin made the change" do
      user.audits.create!(
        action: "update",
        auditable: user,
        user: create(:admin),
        audited_changes: { "login" => ["admin_changed", user.login] },
        remote_address: "203.0.113.50"
      )

      expect(subject).not_to include("203.0.113.50")
    end

    it "finds accounts that currently use the email" do
      current = create(:user, email: email)
      current.audits.create!(
        action: "update",
        auditable: current,
        audited_changes: { "login" => ["former_name", current.login] },
        remote_address: "192.0.2.9"
      )

      expect(subject).to include("former_name")
      expect(subject).to include("192.0.2.9")
    end
  end

  describe "deleted accounts query" do
    it "ends the report with the audits query for a secondary database" do
      expect(subject).to include("ask Systems to run this")
      expect(subject).to include("SELECT DISTINCT auditable_id FROM audits")
      expect(subject).to include("audited_changes LIKE '%guest@example.com%'")
    end

    it "escapes LIKE wildcards in the email" do
      report = described_class.new("gu%es_t@example.com").to_s

      expect(report).to include("LIKE '%gu\\%es\\_t@example.com%'")
    end
  end
end
