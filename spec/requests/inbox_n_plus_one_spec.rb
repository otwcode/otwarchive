require "spec_helper"

describe "n+1 queries in the InboxController" do
  include LoginMacros

  describe "#show" do
    let!(:user) { create(:user) }

    shared_examples "a constant number of queries" do
      context "when displaying multiple inbox comments", n_plus_one: true do
        before { fake_login_known_user(user) }

        populate do |n|
          n.times { create(:inbox_comment, user: user, feedback_comment: build_feedback_comment.call) }
        end

        warmup { get user_inbox_path(user) }

        it "produces a constant number of queries" do
          expect do
            get user_inbox_path(user)
          end.to perform_constant_number_of_queries
        end
      end
    end

    context "with comments from registered users" do
      let(:build_feedback_comment) { -> { create(:comment) } }

      it_behaves_like "a constant number of queries"
    end

    context "with comments from guests" do
      let(:build_feedback_comment) { -> { create(:comment, :by_guest) } }

      it_behaves_like "a constant number of queries"
    end

    context "with reply comments" do
      let(:build_feedback_comment) { -> { create(:comment, commentable: create(:comment)) } }

      it_behaves_like "a constant number of queries"
    end
  end
end
