require "spec_helper"

describe "n+1 queries in the batch_subscription_notification" do
  include LoginMacros

  context "sending a cached work's subscription notification to multiple users", :n_plus_one do
    let!(:orphan_account) { create(:user, login: "orphan_account") }
    let!(:series) { create(:series) }
    let!(:work) { series.works.first }
    let!(:entries) { ["Chapter_#{work.chapter_ids.first}"].to_json }

    populate do |n|
      create_list(:subscription, n, subscribable: work)
      email = UserMailer.batch_subscription_notification(Subscription.first.id, entries) # cache it
      expect(email).to have_html_part_content("posted a new chapter")
    end

    it "generates about 10 database queries per mail" do
      expect do
        Subscription.ids.each do |id|
          email = UserMailer.batch_subscription_notification(id, entries)
          expect(email).to have_html_part_content("posted a new chapter")
        end
      end.to perform_linear_number_of_queries(slope: 10) # These queries happen outside the cached parts of the views, mostly in user_mailer itself
    end
  end
end
