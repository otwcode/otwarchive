require "spec_helper"

describe LastWranglingActivity do
  include ActiveJob::TestHelper

  describe "#notify_inactive_wranglers" do
    let(:user) { create(:tag_wrangler) }

    context "recently active wrangler" do
      let!(:activity) { create(:last_wrangling_activity, user: user, updated_at: 1.day.ago) }

      it "does nothing" do
        expect { LastWranglingActivity.notify_inactive_wranglers }
          .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
      end
    end

    context "one inactive wrangler" do
      let!(:activity) { create(:last_wrangling_activity, user: user, updated_at: 60.days.ago) }
      it "enqueues one email" do
        expect { LastWranglingActivity.notify_inactive_wranglers }
          .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
      end

      it "does not change the timestamp of the last wrangling activity" do
        LastWranglingActivity.notify_inactive_wranglers
        expect(user.reload.last_wrangling_activity.updated_at).to be <= 60.days.ago
      end

      context "the wrangler has already been notified" do
        before do
          expect { LastWranglingActivity.notify_inactive_wranglers }
            .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
        end

        it "doesn't notify the wrangler again" do
          travel_to(40.days.from_now) do
            expect { LastWranglingActivity.notify_inactive_wranglers }
              .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
          end
        end

        context "wrangler wrangles and then goes inactive again" do
          before do
            user.update_last_wrangling_activity
            expect(user.reload.last_wrangling_activity.updated_at).to be >= 1.hour.ago # should be a recent time
          end

          it "notifies the wrangler again" do
            travel_to(40.days.from_now) do
              expect { LastWranglingActivity.notify_inactive_wranglers }
                .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).with(user).exactly(1)
            end
          end
        end
      end

      context "wrangler is excluded from activity checking" do
        let(:user) { create(:tag_wrangler, login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY.last) }

        it "does nothing" do
          expect { LastWranglingActivity.notify_inactive_wranglers }
            .not_to have_enqueued_mail(UserMailer, :inactive_wrangler_notification)
        end
      end
    end

    context "multiple inactive wranglers" do
      let!(:activity) { create(:last_wrangling_activity, user: user, updated_at: 60.days.ago) }
      let(:user2) { create(:tag_wrangler) }
      let!(:activity2) { create(:last_wrangling_activity, user: user2, updated_at: 40.days.ago) }

      it "enqueues multiple emails" do
        expect { LastWranglingActivity.notify_inactive_wranglers }
          .to have_enqueued_mail(UserMailer, :inactive_wrangler_notification).exactly(2)
      end
    end
  end
end
