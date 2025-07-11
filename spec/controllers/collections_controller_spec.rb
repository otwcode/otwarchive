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

    context "when indexing collections for an object" do
      context "when work does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { work_id: 0 }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when work exists" do
        let(:work) { create(:work) }

        it "raises an error" do
          get :index, params: { work_id: work.id }
          expect(response).to render_template :index
        end
      end

      context "when collection does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { collection_id: "not_here" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when collection exists" do
        let(:collection) { create(:collection) }

        it "raises an error" do
          get :index, params: { collection_id: collection.name }
          expect(response).to render_template :index
        end
      end

      context "when user does not exist" do
        it "raises an error" do
          expect do
            get :index, params: { user_id: "not_here" }
          end.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context "when user exists" do
        let(:user) { create(:user) }

        it "raises an error" do
          get :index, params: { user_id: user.login }
          expect(response).to render_template :index
        end
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
