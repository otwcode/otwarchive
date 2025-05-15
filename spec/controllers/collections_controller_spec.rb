require "spec_helper"

describe CollectionsController do
  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and subcollections" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - Subcollections")
    end
  end

  describe "GET #show" do
    context "when collection does not exist" do
      it "raises an error" do
        expect do
          get :show, params: { id: "nonexistent" }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
