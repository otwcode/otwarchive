require "spec_helper"

describe FandomsController, work_search: true do
  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and fandoms" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - Fandoms")
    end
  end
end
