require 'spec_helper'

describe Challenge::GiftExchangeController do
  describe "destroy" do
    before do
      @collection = FactoryGirl.create(:collection, challenge: GiftExchange.new)
      @challenge = @collection.challenge
    end

    it "should remove challenge variables on Collection" do
      @challenge.destroy
      @collection.challenge_id.should eq(nil)
      @collection.challenge_type.should eq(nil)
    end
  end
end