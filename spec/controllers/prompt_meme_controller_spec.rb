require 'spec_helper'

describe Challenge::PromptMemeController do
  include LoginMacros

  describe "destroy" do
    before(:each) do
      @collection = FactoryGirl.create(:collection, challenge: PromptMeme.new)
      @collection.save
      fake_login_known_user(@collection.owners.first.user)
      delete :destroy, id: @collection.challenge.id, collection_id: @collection.name
    end

    it "remove challenge variables on Collection" do
      @collection.reload.challenge_id.should eq(nil)
      @collection.reload.challenge_type.should eq(nil)
    end

    it "sets a flash message" do
      flash[:notice].should eq("Challenge settings were deleted.")
    end

    it "redirects to the collection's main page" do
      response.should redirect_to(@collection)
    end
  end
end
