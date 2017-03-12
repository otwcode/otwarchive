require 'spec_helper'

describe ChallengeAssignmentsController do
  include LoginMacros
  include RedirectExpectationHelper

  context "when not logged in" do
    describe 'no_challenge' do
      it 'error to login page' do
        let(:collection) { create(:collection) }
        get :no_challenge, collection_id: collection.name
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  context "when logged in" do
    describe 'no_challenge' do
      it 'show an error, redirect and return false' do
        let(:collection) { create(:collection) }
        fake_login_known_user(@collection.owners.first.user)
        get :no_challenge, collection_id: @collection.name
        it_redirects_to_with_error(collection_path(@collection), "What challenge did you want to work with?")
      end
    end
  end
end
