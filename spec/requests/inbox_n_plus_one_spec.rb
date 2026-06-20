require "spec_helper"

describe "n+1 queries in the InboxController" do
  include LoginMacros

  describe "#show" do
    let!(:user) { create(:user) }

    shared_examples "a constant number of queries" do |*traits|
      context "when displaying multiple inbox comments", n_plus_one: true do
        before { fake_login_known_user(user) }

        populate { |n| create_list(:inbox_comment, n, *traits, user: user) }

        warmup { get user_inbox_path(user) }

        it "produces a constant number of queries" do
          expect do
            get user_inbox_path(user)
          end.to perform_constant_number_of_queries
        end
      end
    end

    context "with comments from registered users" do
      it_behaves_like "a constant number of queries"
    end

    context "with comments from guests" do
      it_behaves_like "a constant number of queries", :with_guest_comment
    end

    context "with reply comments" do
      it_behaves_like "a constant number of queries", :with_reply_comment
    end
  end
end
