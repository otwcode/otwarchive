require "spec_helper"

describe CollectionsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "hidden works" do
    shared_examples "only author and admin can view work collections page" do
      shared_examples "user can't see work collections" do
        it "redirects user to login page with error message" do
          get :index, params: { work_id: work.id }
          it_redirects_to_with_error(root_path, error_message)
        end
      end

      shared_examples "user can see work collections" do
        it "renders the page" do
          get :index, params: { work_id: work.id }
          expect(response).to render_template(:index)
          expect(assigns(:collections)).to include(collection)
        end
      end

      context "when logged out" do
        it_behaves_like "user can't see work collections" do
          let(:error_message) { "Sorry, you don't have permission to access the page you were trying to reach. Please log in." }
        end
      end

      context "when logged in as a random user" do
        let(:user) { create(:user) }

        before { fake_login_known_user(user) }

        it_behaves_like "user can't see work collections" do
          let(:error_message) { "Sorry, you don't have permission to access the page you were trying to reach." }
        end
      end

      context "when logged in as the work's owner" do
        let(:user) { work.users.first }

        before { fake_login_known_user(user) }

        it_behaves_like "user can see work collections"
      end

      context "when logged in as an admin" do
        let(:user) { create(:admin, roles: ["policy_and_abuse"]) }

        before { fake_login_admin(user) }

        it_behaves_like "user can see work collections"
      end
    end

    let(:author) { create(:user) }
    let!(:work) { create(:work, authors: [author.pseuds.first]) }
    let(:collection) { create(:collection) }

    context "on an unrevealed work" do
      before { work.update!(collection_names: "#{create(:unrevealed_collection).name}, #{collection.name}") }

      it_behaves_like "only author and admin can view work collections page"
    end

    context "on a work hidden by an admin" do
      before do
        work.update!(collection_names: collection.name)
        work.update_column(:hidden_by_admin, true)
      end

      it_behaves_like "only author and admin can view work collections page"
    end
  end
end
