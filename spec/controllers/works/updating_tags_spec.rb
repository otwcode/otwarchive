require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #edit" do
    let(:work) { create(:work) }

    context "when logged in as the work creator" do
      before { fake_login_known_user(work.users.first) }

      it "renders the edit template" do
        get :edit, params: { id: work }
        expect(response).to render_template(:edit)
        expect(assigns(:work)).to eq(work)
      end
    end

    context "when logged in as a random user" do
      before { fake_login }

      it "redirects with an error" do
        get :edit, params: { id: work }
        it_redirects_to_with_error(work_path(work), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: %w[superadmin policy_and_abuse support] do
      let(:work) { create(:work) }

      subject { get :edit, params: { id: work } }
      let(:success) do
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "POST #update_tags" do
    let(:admin) { create(:admin) }
    let(:work) { create(:work) }
    let!(:language) { create(:language) }

    shared_examples "cannot update work tags and language" do
      it "redirects with error" do
        expect do
          post :update_tags, params: {
            id: work, work: { relationship_string: "kronfaumei", language_id: language.id }
          }
        end.to avoid_changing { work.reload.updated_at }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "can update work tags and language" do
      it "updates the work and redirects with notice" do
        post :update_tags, params: {
          id: work, work: { relationship_string: "kronfaumei", language_id: language.id }
        }
        it_redirects_to_with_notice(work_path(work), "Work was successfully updated.")
        expect(work.reload.relationship_string).to eq("kronfaumei")
        expect(work.language).to eq(language)
      end
    end

    context "when logged in as the work creator" do
      before { fake_login_known_user(work.users.first) }

      it_behaves_like "can update work tags and language"
    end

    context "when admin does not have correct authorization" do
      before do
        admin.update!(roles: [])
        fake_login_admin(admin)
      end

      it_behaves_like "cannot update work tags and language"
    end

    %w[superadmin policy_and_abuse support].each do |role|
      context "when admin has #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        before { fake_login_admin(admin) }

        it_behaves_like "can update work tags and language"
      end
    end
  end
end
