require "spec_helper"

describe FandomsController, work_search: true do
  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and fandoms" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - Fandoms")
    end

    context "with media_id param" do
      context "when media_id param doesn't exist" do
        it "raises an error" do
          expect do
            get :index, params: { media_id: "nonexistent" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
