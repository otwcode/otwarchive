require "spec_helper"

describe InactiveWranglerSupervisorNotificationJob do
  include ActiveJob::TestHelper

  let!(:user) { create(:tag_wrangler) }

  context "freshly created wrangler" do
    it "does nothing" do
      expect { InactiveWranglerSupervisorNotificationJob.perform_now }
        .not_to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification)
    end

    context "wrangler never wrangles" do
      it "notifies the supervisors" do
        travel_to(40.days.from_now) do
          expect { InactiveWranglerSupervisorNotificationJob.perform_now }
            .to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification).with([user.login]).exactly(1)
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
      expect { InactiveWranglerSupervisorNotificationJob.perform_now }
        .not_to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification)
    end
  end

  context "one inactive wrangler" do
    before do
      user.last_wrangling_activity.updated_at = 60.days.ago
      user.last_wrangling_activity.save!(touch: false)
    end

    it "enqueues the email" do
      expect { InactiveWranglerSupervisorNotificationJob.perform_now }
        .to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification).with([user.login]).exactly(1)
    end

    it "does not change the timestamp of the last wrangling activity" do
      InactiveWranglerSupervisorNotificationJob.perform_now
      expect(user.reload.last_wrangling_activity.updated_at).to be <= 60.days.ago
    end

    context "supervisors have already been notified" do
      before do
        expect { InactiveWranglerSupervisorNotificationJob.perform_now }
          .to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification).with([user.login]).exactly(1)
      end

      it "doesn't notify the supervisors again" do
        travel_to(40.days.from_now) do
          expect { InactiveWranglerSupervisorNotificationJob.perform_now }
            .not_to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification)
        end
      end

      context "wrangler wrangles and then goes inactive again" do
        before do
          user.update_last_wrangling_activity
          expect(user.reload.last_wrangling_activity.updated_at).to be >= 1.hour.ago # should be a recent time
        end

        it "notifies the supervisors again" do
          travel_to(40.days.from_now) do
            expect { InactiveWranglerSupervisorNotificationJob.perform_now }
              .to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification).with([user.login]).exactly(1)
          end
        end
      end
    end

    context "wrangler is excluded from activity checking" do
      let(:user) { create(:tag_wrangler, login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY.last) }

      it "does nothing" do
        expect(user.reload.last_wrangling_activity.updated_at).to be <= 60.days.ago
        expect { InactiveWranglerSupervisorNotificationJob.perform_now  }
          .not_to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification)
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

    it "enqueues one email" do
      expect { InactiveWranglerSupervisorNotificationJob.perform_now }
        .to have_enqueued_mail(TagWranglingSupervisorMailer, :inactive_wrangler_notification).with(array_including(user.login, user2.login)).exactly(1)
    end
  end
end
