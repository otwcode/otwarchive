require "spec_helper"

describe CollectionsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:collection) { create(:collection) }

  describe "GET #index" do
    it "assigns subtitle with collection title and subcollections" do
      get :index, params: { collection_id: collection.name }
      expect(assigns[:page_subtitle]).to eq("#{collection.title} - Subcollections")
    end

    context "denies access for work that isn't visible to user" do
      subject { get :index, params: { work_id: work } }
      let(:success) { expect(response).to render_template("index") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :index, params: { work_id: work }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
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
