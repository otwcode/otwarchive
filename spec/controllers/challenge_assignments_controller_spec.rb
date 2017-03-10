require 'spec_helper'

describe ChallengeAssignmentsController do
  include LoginMacros
  include RedirectExpectationHelper

  context "when not logged in" do
    describe 'no_challenge' do
      before(:each) do
        @collection = FactoryGirl.create(:collection)
      end
      
      it 'should error to login page' do
        get :no_challenge, collection_id: @collection.name
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end
  end

  context "when logged in" do
    before(:each) do
      @collection = FactoryGirl.create(:collection)
      fake_login_known_user(@collection.owners.first.user)
    end
    
    describe 'no_challenge' do
      it 'should show an error, redirect and return false' do
        get :no_challenge, collection_id: @collection.name
        it_redirects_to_with_error(collection_path(@collection), "What challenge did you want to work with?")
      end
    end
  end
end
