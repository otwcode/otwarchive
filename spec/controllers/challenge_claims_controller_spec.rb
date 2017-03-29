# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ChallengeClaimsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:signup) { create(:challenge_signup) }
  let(:collection) { signup.collection }
  let(:claim) { create(:challenge_claim, collection: collection) }

  describe 'index' do
    it 'assigns claims and gives a notice if the collection is closed and the user is not the maintainer' do
      fake_login_known_user(user)
      allow_any_instance_of(Collection).to receive(:closed?) { true }
      get :index, id: claim.id, collection_id: collection.name, for_user: true
      expect(flash[:notice]).to include("This challenge is currently closed to new posts.")
      expect(assigns(:claims))
    end

    it 'will not allow you to see someone elses claims' do
      second_user = create(:user)
      fake_login_known_user(user)
      get :index, user_id: second_user.login
      it_redirects_to_with_error(root_path, \
                                 "You aren't allowed to see that user's claims.")
    end
  end

  describe 'show' do
    it 'redirects logged in user to the prompt' do
      request_prompt = create(:prompt, collection_id: collection.id, challenge_signup_id: signup.id)
      claim_with_prompt = create(:challenge_claim, collection: collection, request_prompt_id: request_prompt.id)
      fake_login_known_user(user)
      get :show, id: claim_with_prompt.id, collection_id: collection.name
      it_redirects_to(collection_prompt_path(collection, claim_with_prompt.request_prompt))
    end

    xit 'needs a collection' do
      fake_login_known_user(user)
      get :show
      it_redirects_to_with_error(root_path, \
                                 "What challenge did you want to work with?")
    end
  end

  describe 'create' do
    it 'sets a notice and redirects' do
      fake_login_known_user(@user)
      post :create, collection_id: collection.name, challenge_claim: {collection_id: collection.id}
      it_redirects_to_with_notice(collection_claims_path(collection, for_user: true), \
                                  "New claim made.")
    end

    it 'on an exception gives an error and redirects' do
      fake_login_known_user(@user)
      allow_any_instance_of(ChallengeClaim).to receive(:save) { false }
      post :create, collection_id: collection.name, challenge_claim: {collection_id: collection.id}
      it_redirects_to_with_error(collection_claims_path(collection, for_user: true), \
                                 "We couldn't save the new claim.")
    end
  end

  describe 'destory' do
    context 'with a claim' do
      it 'on an exception gives an error and redirects' do
        fake_login_known_user(@user)
        allow_any_instance_of(ChallengeClaim).to receive(:destroy) { raise ActiveRecord::RecordNotDestroyed }
        delete :destroy, id: claim.id, collection_id: collection.name
        it_redirects_to_with_error(collection_claims_path(collection), \
                                   "We couldn't delete that right now, sorry! Please try again later.")
      end
    end
  end
end
