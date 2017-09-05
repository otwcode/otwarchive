require 'spec_helper'

describe ChallengeAssignmentsController do
  include LoginMacros
  include RedirectExpectationHelper

  context "when not logged in" do
    describe 'no_challenge' do
      let(:collection) { create(:collection) }

      it 'error to login page' do
        get :no_challenge, params: { collection_id: collection.name }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    describe "defaulting" do
      it "fails because no user specified" do
        get :no_user
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  context "when logged in" do
    let(:gift_exchange) { create(:gift_exchange) }
    let(:collection) { create(:collection, challenge: gift_exchange, challenge_type: "GiftExchange") }
    let(:user) { collection.owners.first.user }
    let(:otheruser) { create(:user) }

    describe 'no_challenge' do
      let(:collectionwithoutchallenge) { create(:collection) }
      let(:usernochallenge) { collectionwithoutchallenge.owners.first.user }

      it 'show an error, redirect to collection and return false for mod' do
        fake_login_known_user(usernochallenge)
        get :no_challenge, params: { collection_id: collectionwithoutchallenge.name }
        it_redirects_to_with_error(collection_path(collectionwithoutchallenge), "What challenge did you want to work with?")
      end

      it 'show an error, redirect to user and return false for non-mod' do
        fake_login_known_user(user)
        get :no_challenge, params: { collection_id: collectionwithoutchallenge.name }
        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    describe 'no_assignment with collection' do
      it 'show an error, redirect and return false' do
        fake_login_known_user(user)
        get :no_assignment, params: { collection_id: collection.name }
        it_redirects_to_with_error(collection_path(collection), "What assignment did you want to work on?")
      end
    end

    describe 'no_assignment with no collection' do
      it 'show an error, redirect and return false' do
        fake_login_known_user(user)
        get :no_assignment
        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    describe "defaulting" do
      let(:open_assignment) { create(:challenge_assignment, collection_id: collection.id) }

      it "fails if user not specified" do
        fake_login_known_user(user)
        get :no_user, params: { collection_id: collection.name }
        it_redirects_to_with_error(root_path, "What user were you trying to work with?")
      end

      it "fails if you're not the owner of the assignment you're defaulting on" do
        fake_login_known_user(user)
        gift_exchange.assignments_sent_at = Time.now
        gift_exchange.save
        # tests :owner_only, but you can't access that directly or it won't load @challenge_assignment
        get :default, params: { collection_id: collection.name, id: open_assignment, user_id: user.login }
        it_redirects_to_with_error(root_path, "You aren't the owner of that assignment.")
      end
    end

    describe "show" do
      let(:defaulted_assignment) { create(:challenge_assignment, collection_id: collection.id, defaulted_at: Time.now) }

      it "won't show if you're not the right user" do
        fake_login_known_user(otheruser)
        get :show, params: { id: defaulted_assignment.id, collection_id: collection.id }
        it_redirects_to_with_error(root_path, "You aren't allowed to see that assignment!")
      end

      it "will tell you if you've defaulted" do
        fake_login_known_user(defaulted_assignment.offering_user)
        get :show, params: { id: defaulted_assignment.id, collection_id: collection.id }
        expect(response).to have_http_status(:success)
        expect(flash[:notice]).to include "This assignment has been defaulted-on."
      end
    end

    describe "index" do
      render_views
      let!(:open_assignment) { create(:challenge_assignment, collection_id: collection.id) }
      let!(:defaulted_assignment) { create(:challenge_assignment, collection_id: collection.id, defaulted_at: Time.now) }

      it "errors if you're not a mod and try to see someone else's assignment" do
        fake_login_known_user(otheruser)
        get :index, params: { collection_id: collection.name, user_id: user.default_pseud }
        it_redirects_to_with_error(root_path, "You aren't allowed to see that user's assignments.")
      end

      it "shows defaulted assignments within a collection" do
        fake_login_known_user(user)
        get :index, params: { collection_id: collection.name }
        expect(response).to have_http_status(:success)
        expect(response.body).to include "Assignments for"
        expect(response.body).to include collection.title
        expect(response.body).to include defaulted_assignment.request_byline
        expect(response.body).not_to include "No assignments to review!"
      end

      it "shows unfulfilled assignments within a collection" do
        fake_login_known_user(user)
        get :index, params: { collection_id: collection.name, unfulfilled: true }
        expect(response).to have_http_status(:success)
        expect(response.body).to include "Assignments for"
        expect(response.body).to include collection.title
        expect(response.body).to include open_assignment.request_byline
        expect(response.body).not_to include "No assignments to review!"
      end

      it "won't show specific to that user and collection for offering user" do
        # this could still do with further expansion
        fake_login_known_user(open_assignment.offering_user)
        get :index, params: { collection_id: collection.name, user_id: open_assignment.offering_user.id }
        it_redirects_to_with_error(user_path(open_assignment.offering_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "shows specific to that user and collection for mod" do
        fake_login_known_user(user)
        get :index, params: { collection_id: collection.name, user_id: open_assignment.offering_user.id }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
