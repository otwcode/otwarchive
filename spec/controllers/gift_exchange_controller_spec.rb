require 'spec_helper'

describe Challenge::GiftExchangeController do
  before do
    @collection = FactoryGirl.create(:collection, challenge: GiftExchange.new)
    @collection.save
    @challenge = @collection.challenge
    @challenge.save

  end
  describe "destroy" do

    xit "should remove challenge variables on Collection" do
      @challenge.destroy
      @challenge.save
      @collection.challenge_id.should eq(nil)
      @collection.challenge_type.should eq(nil)
    end
  end
end