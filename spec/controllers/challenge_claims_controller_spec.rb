require 'spec_helper'

RSpec.describe ChallengeClaimsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  begin
    @user = FactoryGirl.create(:user)
  end

  describe 'destory' do
    context 'with a claim' do
      before do
        @signups = create(:challenge_signup)
        @collection = @signups.collection
        @claim = create(:challenge_claim)
      end
      it 'on an exception gives an error and redirects' do
        fake_login_known_user(@user)
        allow_any_instance_of(ChallengeClaim).to receive(:destroy) { raise ActiveRecord::RecordNotDestroyed }
        delete :destroy, id: @claim.id, collection_id: @collection.name
        it_redirects_to_with_error(collection_claims_path(@collection), \
                                   "We couldn't delete that right now, sorry! Please try again later.")
      end
    end
  end
end
