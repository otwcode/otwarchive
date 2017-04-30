require 'spec_helper'

describe Challenge::GiftExchangeController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "destroy" do
    before(:each) do
      @collection = FactoryGirl.create(:collection, challenge: GiftExchange.new)
      @collection.save
      fake_login_known_user(@collection.owners.first.user)
      delete :destroy, id: @collection.challenge.id, collection_id: @collection.name
    end

    it "remove challenge variables on Collection" do
      expect(@collection.reload.challenge_id).to be_nil
      expect(@collection.reload.challenge_type).to be_nil
    end

    it "redirects to the collection's main page with a notice" do
      it_redirects_to_with_notice(@collection, "Challenge settings were deleted.")
    end
  end
end
