require "spec_helper"

describe Admin::TotpController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #new" do
    let(:admin) { create(:admin) }
    let(:other_admin) { create(:admin, otp_required_for_login: true) }

    it "denies access to guest users" do
      get :new, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :new, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      it "allows access to their own page when TOTP is disabled" do
        fake_login_admin(admin)
        get :new, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to their own page when TOTP is enabled" do
        fake_login_admin(other_admin)
        get :new, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :new, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #reauthenticate_create" do
    let(:admin) { create(:admin, password: "correct_password") }
    let(:other_admin) { create(:admin, otp_required_for_login: true) }

    it "denies access to guest users" do
      post :reauthenticate_create, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      post :reauthenticate_create, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_totp_secret_if_missing!
      end

      it "continues to enabling TOTP form when the password is correct" do
        fake_login_admin(admin)
        post :reauthenticate_create, params: { admin_id: admin.login, password_check: "correct_password" }
        expect(flash).to be_empty
        expect(response).to render_template(:confirm_enable)
      end

      it "denies access when password is wrong" do
        fake_login_admin(admin)
        post :reauthenticate_create, params: { admin_id: admin.login, password_check: "wrong_password" }
        expect(admin.reload.totp_enabled?).to be_falsey
        expect(flash[:error]).to eq("Your password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form.")
      end

      it "denies access when TOTP is enabled" do
        fake_login_admin(other_admin)
        post :reauthenticate_create, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        post :reauthenticate_create, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #create" do
    let(:admin) { create(:admin) }
    let(:other_admin) { create(:admin, otp_required_for_login: true) }

    it "denies access to guest users" do
      post :create, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      post :create, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_totp_secret_if_missing!
      end

      it "allows enabling TOTP" do
        fake_login_admin(admin)
        post :create, params: { admin_id: admin.login, totp_attempt: admin.current_otp }
        expect(admin.reload.totp_enabled?).to be_truthy
        it_redirects_to_with_notice(show_backup_codes_admin_totp_path, "Successfully enabled two-step verification; please make note of your backup codes.")
      end

      it "denies access when TOTP code is wrong" do
        fake_login_admin(admin)
        post :create, params: { admin_id: admin.login, totp_attempt: "000000" }
        expect(admin.reload.totp_enabled?).to be_falsey
        expect(flash[:error]).to eq("Incorrect verification code. Your code may have expired, or you may need to set up your authenticator app again.")
      end

      it "denies access when TOTP is enabled" do
        fake_login_admin(other_admin)
        post :create, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        post :create, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "GET #show_backup_codes" do
    let(:admin) { create(:admin, otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      get :show_backup_codes, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :show_backup_codes, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_totp_secret_if_missing!
      end

      it "shows the backup codes once" do
        fake_login_admin(admin)
        get :show_backup_codes, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :show_backup_codes, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        get :show_backup_codes, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(new_admin_totp_path, "Please enable two-step verification first.")
      end
    end
  end

  describe "GET #confirm_disable" do
    let(:admin) { create(:admin, otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      get :confirm_disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :confirm_disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_totp_secret_if_missing!
        admin.generate_otp_backup_codes!
        admin.save!
      end

      it "allows access to their own page when TOTP is enabled" do
        fake_login_admin(admin)
        get :confirm_disable, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        get :confirm_disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path,
                                   "TOTP two-step verification is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :confirm_disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #disable_totp" do
    let(:admin) { create(:admin, password: "correct_password", otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      post :disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      post :disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_totp_secret_if_missing!
        admin.generate_otp_backup_codes!
        admin.save!
      end

      it "allows disabling TOTP" do
        fake_login_admin(admin)
        post :disable, params: { admin_id: admin.login, password_check: "correct_password" }
        expect(admin.reload.totp_enabled?).to be_falsey
        it_redirects_to_with_notice(admins_path, "Successfully disabled two-step verification.")
      end

      it "denies access when password is wrong" do
        fake_login_admin(admin)
        post :disable, params: { admin_id: admin.login, password_check: "wrong_password" }
        expect(admin.reload.totp_enabled?).to be_truthy
        expect(flash[:error]).to eq("Your password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        post :disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path,
                                   "TOTP two-step verification is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        post :disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
