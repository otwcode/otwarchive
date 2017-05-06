require 'spec_helper'

describe ChallengeAssignmentsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:collection) { create(:collection) }

  context "when not logged in" do
    describe 'no_challenge' do
      it 'error to login page' do
        get :no_challenge, collection_id: collection.name
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  context "when logged in" do
    let(:gift_exchange) { create(:gift_exchange) }
    let(:collection2) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let(:offer) { create(:challenge_signup, collection: collection2, pseud: user2.default_pseud) }
    let(:offer2) { create(:challenge_signup, collection: collection2, pseud: otheruser.default_pseud) }
    let(:open_assignment) { create(:challenge_assignment, collection: collection2, offer_signup: offer2) }
    let(:defaulted_assignment) { create(:challenge_assignment, collection: collection2, offer_signup: offer, defaulted_at: Time.now) }
    let(:user) { collection.owners.first.user }
    let(:user2) { collection2.owners.first.user }
    let(:otheruser) { create(:user) }

    describe 'no_challenge' do
      it 'show an error, redirect and return false' do
        fake_login_known_user(user)
        get :no_challenge, collection_id: collection.name
        it_redirects_to_with_error(collection_path(collection), "What challenge did you want to work with?")
      end
    end

    describe 'no_assignment with collection' do
      it 'show an error, redirect and return false' do
        fake_login_known_user(user2)
        get :no_assignment, collection_id: collection2.name
        it_redirects_to_with_error(collection_path(collection2), "What assignment did you want to work on?")
      end
    end

    describe 'no_assignment with no collection' do
      it 'show an error, redirect and return false' do
        fake_login_known_user(user)
        get :no_assignment
        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    describe "show" do
      it "won't show if you're not the right user" do
        fake_login_known_user(otheruser)
        get :show, id: defaulted_assignment.id
        it_redirects_to_with_error(root_path, "You aren't allowed to see that assignment!")
      end

      it "will tell you if you've defaulted" do
        fake_login_known_user(user2)
        get :show, id: defaulted_assignment.id
        expect(response).to have_http_status(:success)
        expect(flash[:notice]).to include "This assignment has been defaulted-on."
      end
    end

    describe "index" do
      render_views

      it "errors if you're not a mod and try to see someone else's assignment" do
        fake_login_known_user(otheruser)
        get :index, collection_id: collection2.name, user_id: user2.default_pseud
        it_redirects_to_with_error(root_path, "You aren't allowed to see that user's assignments.")
      end
    end
  end
end
