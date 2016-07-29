require 'spec_helper'

describe Challenge::GiftExchangeController do
  include LoginMacros

  describe '#destroy' do
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @collection = FactoryGirl.create(:collection, challenge: GiftExchange.new)
      user_login @collection.owners.first.user
      delete :destroy, id: @collection.challenge.id, collection_id: @collection.name
    end

    it "remove challenge variables on Collection" do
      expect(@collection.reload.challenge_id).to eq(nil)
      expect(@collection.reload.challenge_type).to eq(nil)
    end

    it "sets a flash message" do
      expect(flash[:notice]).to eq("Challenge settings were deleted.")
    end

    it "redirects to the collection's main page" do
      expect(response).to redirect_to(@collection)
    end
  end
end
