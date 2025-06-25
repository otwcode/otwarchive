require "spec_helper"

describe InactiveWranglerNotificationJob do
  include ActiveJob::TestHelper

  let!(:user) { create(:tag_wrangler) }

  context "freshly created wrangler" do
    it "does nothing" do
      expect { InactiveWranglerNotificationJob.perform_now }
        .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
    end

    context "wrangler never wrangles" do
      it "notifies the wrangler" do
        travel_to(40.days.from_now) do
          expect { InactiveWranglerNotificationJob.perform_now }
            .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
        end
      end
    end
  end

  context "recently active wrangler" do
    before do
      user.last_wrangling_activity.updated_at = 1.day.ago
      user.last_wrangling_activity.save!(touch: false)
    end

    it "does nothing" do
      expect { InactiveWranglerNotificationJob.perform_now }
        .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
    end
  end

  context "one inactive wrangler" do
    before do
      user.last_wrangling_activity.updated_at = 60.days.ago
      user.last_wrangling_activity.save!(touch: false)
    end

    it "enqueues one email" do
      expect { InactiveWranglerNotificationJob.perform_now }
        .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
    end

    it "does not change the timestamp of the last wrangling activity" do
      InactiveWranglerNotificationJob.perform_now
      expect(user.reload.last_wrangling_activity.updated_at).to be <= 60.days.ago
    end

    context "wrangler has already been notified" do
      before do
        expect { InactiveWranglerNotificationJob.perform_now }
          .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
      end

      it "doesn't notify the wrangler again" do
        travel_to(40.days.from_now) do
          expect { InactiveWranglerNotificationJob.perform_now }
            .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
        end
      end
    end

    context "wrangler is excluded from activity checking" do
      let(:system_username) { "AO3_Wrangling_Project" }
      let(:user) { create(:tag_wrangler, login: system_username) }

      before { allow(ArchiveConfig).to receive(:USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY).and_return([system_username, "some_other_system_user"]) }

      it "does nothing" do
        expect(user.reload.last_wrangling_activity.updated_at).to be <= 60.days.ago
        expect { InactiveWranglerNotificationJob.perform_now }
          .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
      end
    end
  end

  context "multiple inactive wranglers" do
    let(:user2) { create(:tag_wrangler) }

    before do
      user.last_wrangling_activity.updated_at = 60.days.ago
      user.last_wrangling_activity.save!(touch: false)
      user2.last_wrangling_activity.updated_at = 40.days.ago
      user2.last_wrangling_activity.save!(touch: false)
    end

    it "enqueues multiple emails" do
      expect { InactiveWranglerNotificationJob.perform_now }
        .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).exactly(2)
    end
  end
end
