# frozen_string_literal: true

require "spec_helper"

describe AuditsBackfillJob do
  let(:existing_user) { create(:user) }

  context "when audits previously exist" do
    before do
      # Manually create audit record so user_past_usernames isn't updated
      existing_user.audits.create!(action: "update", auditable: existing_user, user: existing_user,
                                   auditable_id: existing_user.id, audited_changes: { "login" => ["old_login", existing_user.login] })
      existing_user.audits.create!(action: "update", auditable: existing_user, user: existing_user,
                                   auditable_id: existing_user.id, audited_changes: { "email" => ["old@example.com", existing_user.email] })
    end

    it "creates backfilled records in user_past_usernames" do
      user_ids = [existing_user.id]
      AuditsBackfillJob.new.perform_on_batch(user_ids)
      expect(existing_user.past_usernames.last.username).to eq("old_login")
    end

    it "creates backfilled records in user_past_emails" do
      user_ids = [existing_user.id]
      AuditsBackfillJob.new.perform_on_batch(user_ids)
      expect(existing_user.past_emails.last.email_address).to eq("old@example.com")
    end

    it "contains both backfilled and new changes" do
      user_ids = [existing_user.id]
      AuditsBackfillJob.new.perform_on_batch(user_ids)
      old_username = existing_user.login
      existing_user.update!(login: "new_login")
      expect(existing_user.past_usernames.count).to eq(2)
      expect(existing_user.past_usernames.last.username).to eq(old_username)
      expect(existing_user.past_usernames.first.username).to eq("old_login")
    end
  end

  it "doesn't create duplicate records" do
    # change with update first, then run backfill
    old_username = existing_user.login
    existing_user.update!(login: "new_login")
    user_ids = [existing_user.id]
    AuditsBackfillJob.new.perform_on_batch(user_ids)

    expect(existing_user.past_usernames.count).to eq(1)
    expect(existing_user.past_usernames.last.username).to eq(old_username)
  end
  
  it "handles audits with a empty field" do
    existing_user.audits.create!(action: "update", auditable: existing_user, user: existing_user,
                                 auditable_id: existing_user.id, audited_changes: { "email" => ["", existing_user.email] })
    user_ids = [existing_user.id]
    AuditsBackfillJob.new.perform_on_batch(user_ids)
    expect(existing_user.past_emails.count).to eq(0)
  end
end
