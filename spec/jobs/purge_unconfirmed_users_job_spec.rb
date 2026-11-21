require "spec_helper"

describe PurgeUnconfirmedUsersJob do
  let(:admin_setting) { AdminSetting.first || AdminSetting.create! }

  before do
    # value is in weeks.
    admin_setting.update_attribute(:days_to_purge_unactivated, 14)
  end

  context "when the unconfirmed account is younger than two weeks" do
    it "doesn't delete the account" do
      unconfirmed = travel_to(13.days.ago) do
        create(:user, :unconfirmed)
      end

      PurgeUnconfirmedUsersJob.perform_now

      expect { unconfirmed.reload }
        .not_to raise_exception
    end
  end

  context "when the unconfirmed account is older than two weeks" do
    it "deletes the account" do
      unconfirmed = travel_to(15.days.ago) do
        create(:user, :unconfirmed)
      end

      PurgeUnconfirmedUsersJob.perform_now

      expect { unconfirmed.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "resets the account's invitation" do
      invitation = create(:invitation)

      unconfirmed = travel_to(15.days.ago) do
        create(:user, :unconfirmed, invitation_token: invitation.token)
      end

      invitation.reload
      expect(invitation.redeemed_at).not_to be_nil
      expect(invitation.invitee).to eq(unconfirmed)

      PurgeUnconfirmedUsersJob.perform_now

      invitation.reload
      expect(invitation.redeemed_at).to be_nil
      expect(invitation.invitee).to be_nil
    end
  end

  context "when the account is confirmed" do
    it "doesn't delete the account" do
      confirmed = travel_to(15.days.ago) do
        create(:user)
      end

      PurgeUnconfirmedUsersJob.perform_now

      expect { confirmed.reload }
        .not_to raise_exception
    end
  end
end
