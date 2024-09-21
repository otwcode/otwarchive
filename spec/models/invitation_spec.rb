require 'spec_helper'

describe Invitation, :ready do

  describe "Create" do

    context "Create Invite with email" do

      let(:user) {build(:user)}
      let(:invite) {build(:invitation, invitee_email: user.email)}
      it "is created with an invitation token" do
        expect(invite.save).to be_truthy
        expect(invite.token).not_to be_nil
      end

    end

    context "Create Invite without email" do

      let(:user) {build(:user)}
      let(:invite) {build(:invitation, invitee_email: user.email)}
      it "is created with an invitation token" do
        expect(invite.save).to be_truthy
        expect(invite.token).not_to be_nil
      end

    end

    context "Create Invitation for existing user" do

      before(:each) do
        @user = create(:user)
      end

      let(:invite_for_existing) {build(:invitation, invitee_email: @user.email)}
      it "cannot be created" do
        expect(invite_for_existing.save).to be_falsey
        expect(invite_for_existing.errors.full_messages).to include(
          'Invitee email is already being used by an account holder.'
        )
      end
    end

    context "Create Invitation for invalid emails" do
      BAD_EMAILS.each do |email|
        let(:bad_email) { build(:invitation, invitee_email: email) }
        it "cannot be created if the email does not pass format check" do
          expect(bad_email.save).to be_falsey
          expect(bad_email.errors[:invitee_email]).to include("should look like an email address. Please use a different address or leave blank.")
        end
      end
    end
  end

  describe "Update" do

    context "Update Invitation for existing user" do

      let(:user) {create(:user)}
      let(:invite_for_existing) {build(:invitation, invitee_email: user.email)}
      it "cannot be created" do
        expect(invite_for_existing.save).to be_falsey
        expect(invite_for_existing.errors.full_messages).to include(
          'Invitee email is already being used by an account holder.'
        )
      end
    end

    context "Sending an invitation to a valid email" do
      let(:invite) { build(:invitation, invitee_email: "foo@example.com") }

      it "succeeds and 'sent_at' is set" do
        expect(invite.save).to be_truthy
        expect(invite.reload.sent_at).not_to be_nil
      end
    end
  end

  describe "#can_resend?" do
    # Support old invites when AO3-6094 wasn't fixed.
    context "without sent_at" do
      let(:broken_invite) { create(:invitation) }

      before do
        broken_invite.sent_at = nil
        broken_invite.save(validate: false)
        expect(broken_invite.reload.sent_at).to be_nil
      end

      it "cannot be resent before set period" do
        travel(5.minutes)
        expect(broken_invite.can_resend?).to be false
      end

      it "can be resent after set period" do
        travel((ArchiveConfig.HOURS_BEFORE_RESEND_INVITATION + 1).hours)
        expect(broken_invite.can_resend?).to be true
      end
    end

    context "with sent_at" do
      let!(:invite) { create(:invitation) }

      it "cannot be resent before set period" do
        travel(5.minutes)
        expect(invite.can_resend?).to be false
      end

      it "can be resent after set period" do
        travel((ArchiveConfig.HOURS_BEFORE_RESEND_INVITATION + 1).hours)
        expect(invite.can_resend?).to be true
      end
    end
  end
end
