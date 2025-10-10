require "spec_helper"

describe "n+1 queries in the batch_subscription_notification" do
  include LoginMacros

  context "sending a work's subscription notification to multiple users", :n_plus_one do
    let!(:orphan_account) { create(:user, login: "orphan_account") }
    let!(:series) { create(:series) }
    let!(:work) { series.works.first }
    let!(:entries) { ["Chapter_#{work.chapter_ids.first}"].to_json }

    populate do |n|
      create_list(:subscription, n, subscribable: work)
      email = UserMailer.batch_subscription_notification(Subscription.first.id, entries) # cache it
      expect(email).to have_html_part_content("posted a new chapter")
    end

    it "performs a constant number of queries" do
      expect do
        Subscription.ids.each do |id|
          email = UserMailer.batch_subscription_notification(id, entries)
          expect(email).to have_html_part_content("posted a new chapter")
        end
      end.to perform_constant_number_of_queries # TODO Bilka this currently fails
    end
  end
end
