require 'spec_helper'

describe Challenge::PromptMemeController do
  include LoginMacros

  describe "new" do
    context "when the collection already has a challenge" do
      before do
        @collection = FactoryGirl.create(:collection, challenge: PromptMeme.new)
        fake_login_known_user(@collection.owners.first.user)
        post :new, params: { collection_id: @collection.name }
      end

      it "should set flash notice" do
        expect(flash[:notice]).to eq("There is already a challenge set up for this collection.")
      end

      it "should redirect to edit meme collection path" do
        expect(response).to redirect_to(edit_collection_prompt_meme_path(@collection))
      end
    end
  end

  describe "update" do
    context "when it fails to udpate parameters" do
      before do
        challenge = PromptMeme.new
        @collection = FactoryGirl.create(:collection, challenge: challenge)
        fake_login_known_user(@collection.owners.first.user)
        allow_any_instance_of(PromptMeme).to receive(:update_attributes).and_return(false)
        allow(controller).to receive(:prompt_meme_params).and_return({})
        post :update, params: { collection_id: @collection.name, propmt_meme: {} }
      end

      it "should render edit page" do
        expect(response).to render_template "edit"
      end

      after do
        allow(controller).to receive(:prompt_meme_params).and_call_original
        allow_any_instance_of(PromptMeme).to receive(:update_attributes).and_call_original
      end
    end
  end

  describe "destroy" do
    before(:each) do
      @collection = FactoryGirl.create(:collection, challenge: PromptMeme.new)
      @collection.save
      fake_login_known_user(@collection.owners.first.user)
      delete :destroy, params: { id: @collection.challenge.id, collection_id: @collection.name }
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
