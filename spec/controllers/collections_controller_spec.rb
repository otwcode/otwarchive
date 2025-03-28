require "spec_helper"

describe CollectionsController do
  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and subcollections" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - Subcollections")
    end
  end
end
