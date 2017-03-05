require 'spec_helper'

RSpec.describe ChallengeClaimsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:signups) { create(:challenge_signup) }
  let(:collection) { signups.collection }
  let(:claim) { create(:challenge_claim) }

  describe 'create' do
    it 'sets a notice and redirects' do
      fake_login_known_user(@user)
      post :create, collection_id: collection.name
      it_redirects_to_with_notice(collection_claims_path(collection, for_user: true), \
                                  "New claim made.")
    end

    it 'on an exception gives an error and redirects' do
      fake_login_known_user(@user)
      allow_any_instance_of(ChallengeClaim).to receive(:save) { false}
      post :create, collection_id: collection.name
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
