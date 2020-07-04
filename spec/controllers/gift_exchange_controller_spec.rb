# frozen_string_literal: true

require 'spec_helper'

describe Challenge::GiftExchangeController do
  include LoginMacros
  include RedirectExpectationHelper

  before(:each) do
    @collection = FactoryBot.create(:collection, challenge: GiftExchange.new)
    @collection.save
    fake_login_known_user(@collection.owners.first.user)
  end

  describe "new" do
    context "when a gift exchange challenge already exists for the collection" do
      before do
        post :new, params: { collection_id: @collection.name }
      end

      it "sets a flash message" do
        expect(flash[:notice]).to eq("There is already a challenge set up for this collection.")
      end

      it "redirects to the collection's gift exchange edit page" do
        expect(response).to redirect_to(edit_collection_gift_exchange_path(@collection))
      end
    end
  end

  describe "create" do
    context "when freeform_num_required is negative (fails to save)" do
      it "renders the new template" do
        post :create, params: { collection_id: @collection.name, gift_exchange: { requests_num_required: -1 } }
        expect(response).to render_template("new")
      end
    end
  end

  describe "update" do
    context "when freeform_num_required is negative (fails to save)" do
      it "renders the edit template" do
        post :update, params: { collection_id: @collection.name, gift_exchange: { requests_num_required: -1 } }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "destroy" do
    before(:each) do
      delete :destroy, params: { id: @collection.challenge.id, collection_id: @collection.name }
    end

    it "removes challenge variables on Collection" do
      expect(@collection.reload.challenge_id).to eq(nil)
      expect(@collection.reload.challenge_type).to eq(nil)
    end

    it "redirects to the collection's main page with a notice" do
      it_redirects_to_with_notice(@collection, "Challenge settings were deleted.")
    end
  end
end
