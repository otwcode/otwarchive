# frozen_string_literal: true

require "spec_helper"

def create_audits(user)
  user.audits.delete_all

  user.audits.create!(action: "create", auditable: user, user: user, auditable_id: user.id,
                      auditable_type: "User", audited_changes: user.to_json,
                      created_at: (ArchiveConfig.USER_KEEP_AUDIT_CREATES_DESTROYS_DAYS + 1).days.ago)

  user.audits.create!(action: "update", auditable: user, user: user, auditable_id: user.id,
                      auditable_type: "User", audited_changes: { "sign_in_count" => [0, 1] },
                      created_at: (ArchiveConfig.USER_KEEP_AUDIT_UPDATES_DAYS + 1).days.ago)

  user.audits.create!(action: "update", auditable: user, user: user, auditable_id: user.id,
                      auditable_type: "User", audited_changes: { "sign_in_count" => [1, 2] },
                      created_at: Time.now.utc)

  user.audits.create!(action: "destroy", auditable: user, user: user, auditable_id: user.id,
                      auditable_type: "User", audited_changes: user.to_json,
                      created_at: Time.now.utc)
end

describe AuditsCleanupJob do
  let(:existing_user) { create(:user) }
  let(:no_cleanup_user) { create(:user) }

  before do
    ArchiveConfig.USER_KEEP_AUDIT_UPDATES_DAYS = 30
    ArchiveConfig.USER_KEEP_AUDIT_CREATES_DESTROYS_DAYS = 30
  end

  context "when old audits exist" do
    before do
      create_audits(existing_user)
    end

    it "deletes audit records older than the configured limits" do
      AuditsCleanupJob.perform
      expect(existing_user.audits.count).to eq(2)
    end

    it "doesn't delete 'update' audit records when configured limit is -1" do
      ArchiveConfig.USER_KEEP_AUDIT_UPDATES_DAYS = -1
      AuditsCleanupJob.perform
      expect(existing_user.audits.where(action: "update").count).to eq(2)
    end

    it "doesn't delete 'create' or 'destroy' audit records when configured limit is -1" do
      ArchiveConfig.USER_KEEP_AUDIT_CREATES_DESTROYS_DAYS = -1
      AuditsCleanupJob.perform
      expect(existing_user.audits.where(action: %w[create destroy]).count).to eq(2)
    end
  end

  context "when audits exist for protected users" do
    before do
      admin_setting = AdminSetting.default
      admin_setting.preserve_audit_records_usernames = [no_cleanup_user.login, "non_existing_user"].join(", ")
      admin_setting.save(validate: false)

      create_audits(existing_user)
      create_audits(no_cleanup_user)
    end

    it "doesn't delete audit records for users whose usernames are in preserve_audit_records_usernames admin setting" do
      AuditsCleanupJob.perform
      expect(no_cleanup_user.audits.count).to eq(4)
    end

    it "does delete audit records for users whose username are not in preserve_audit_records_usernames admin setting" do
      AuditsCleanupJob.perform
      expect(existing_user.audits.count).to eq(2)
    end
  end
end
