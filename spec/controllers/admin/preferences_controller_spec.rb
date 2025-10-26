require "spec_helper"

describe Admin::PreferencesController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      get :show, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :show, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      it "allows access to their own page" do
        fake_login_admin(admin)
        get :show, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :show, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
