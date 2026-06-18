require "spec_helper"

describe "n+1 queries in the InboxController" do
  include LoginMacros

  describe "#show" do
    let!(:user) { create(:user) }

    context "when displaying multiple inbox comments", n_plus_one: true do
      before { fake_login_known_user(user) }

      populate { |n| create_list(:inbox_comment, n, user: user) }

      warmup { get user_inbox_path(user) }

      it "produces a constant number of queries" do
        expect do
          get user_inbox_path(user)
        end.to perform_constant_number_of_queries
      end
    end
  end
end
