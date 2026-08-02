require "spec_helper"

describe "n+1 queries in the inbox module on the homepage: " do
  include LoginMacros

  describe "#show", n_plus_one: true do
    context "displaying a user's unread messages on the homepage" do
      let!(:user) { create(:user) }

      shared_examples "a constant number of queries" do
        before { fake_login_known_user(user) }

        populate do |n|
          create_list(:inbox_comment, n, user: user, feedback_comment: build_feedback_comment.call)
        end

        warmup { get "/" }

        it "displys the right number of comments" do
          get "/"
          expect(response.body.scan('id="feedback_comment_').size).to eq(current_scale.to_i)
        end

        it "produces a constant number of queries" do
          expect do
            get "/"
          end.to perform_constant_number_of_queries
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
end
