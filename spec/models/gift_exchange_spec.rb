require 'spec_helper'

describe GiftExchange do

  describe "a gift exchange challenge" do
    before do
      @collection = FactoryGirl.create(:collection)
      @collection.challenge = GiftExchange.new
      @challenge = @collection.challenge
    end

    it "should save" do
      @challenge.save.should be_true
    end

  end

end