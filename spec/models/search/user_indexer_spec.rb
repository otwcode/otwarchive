require "spec_helper"

describe UserIndexer, user_search: true do
  describe "#index_documents" do
    context "with multiple users in a batch", :n_plus_one do
      populate do |n|
        create_list(:tag_wrangler, n).each do |user|
          user.past_usernames.create!(username: "old", changed_at: 1.day.ago)
          user.past_emails.create!(email_address: "old@example.com", changed_at: 1.day.ago)
        end
      end

      it "generates a constant number of database queries" do
        expect do
          UserIndexer.new(User.ids).index_documents
        end.to perform_constant_number_of_queries
      end
    end
  end
end
