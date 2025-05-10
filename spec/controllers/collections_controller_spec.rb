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
  end
end
