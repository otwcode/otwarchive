require 'spec_helper'

describe ChallengeAssignmentsController do
  include LoginMacros

  context "when not logged in" do
    describe 'no_challenge' do
      before(:each) do
        @collection = FactoryGirl.create(:collection)
        @collection.save
      end
      
      it 'should error to login page' do
        get :no_challenge, collection_id: @collection.name
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:error]).to eq "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
      end
    end
  end

  context "when logged in" do
    before(:each) do
      @collection = FactoryGirl.create(:collection)
      @collection.save
      fake_login_known_user(@collection.owners.first.user)
    end
    
    describe 'no_challenge' do
      it 'should show an error, redirect and return false' do
        get :no_challenge, collection_id: @collection.name
        expect(flash[:error]).to eq "What challenge did you want to work with?"
        expect(response).to redirect_to(collection_path(@collection))
      end
    end
  end
end
