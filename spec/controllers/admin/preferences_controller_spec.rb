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
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end

  describe "GET #totp_setup" do
    let(:admin) { create(:admin) }
    let(:other_admin) { create(:admin, otp_required_for_login: true) }

    it "denies access to guest users" do
      get :totp_setup, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :totp_setup, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      it "allows access to their own page when TOTP is disabled" do
        fake_login_admin(admin)
        get :totp_setup, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to their own page when TOTP is enabled" do
        fake_login_admin(other_admin)
        get :totp_setup, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-factor authentication is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :totp_setup, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end

  describe "POST #totp_setup_form" do
    let(:admin) { create(:admin, password: "correct_password") }
    let(:other_admin) { create(:admin, otp_required_for_login: true) }

    it "denies access to guest users" do
      post :totp_setup_form, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      post :totp_setup_form, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_otp_secret_if_missing!
      end

      it "allows enabling TOTP" do
        fake_login_admin(admin)
        post :totp_setup_form, params: { admin_id: admin.login, admin: { otp_attempt: admin.current_otp, password: "correct_password" } }
        expect(admin.reload.otp_required_for_login).to be_truthy
        it_redirects_to_with_notice(totp_setup_backup_codes_admin_preferences_path, "Successfully enabled two-factor authentication; please make note of your backup codes.")
      end

      it "denies access when TOTP code is wrong" do
        fake_login_admin(admin)
        post :totp_setup_form, params: { admin_id: admin.login, admin: { otp_attempt: "000000", password: "correct_password" } }
        expect(admin.reload.otp_required_for_login).to be_falsey
        it_redirects_to_with_error(totp_setup_admin_preferences_path, "Incorrect authentication code. Your code may have expired, or you may need to re-setup your authenticator app.")
      end

      it "denies access when password is wrong" do
        fake_login_admin(admin)
        post :totp_setup_form, params: { admin_id: admin.login, admin: { otp_attempt: admin.current_otp, password: "wrong_password" } }
        expect(admin.reload.otp_required_for_login).to be_falsey
        it_redirects_to_with_error(totp_setup_admin_preferences_path, "The password or admin username you entered doesn't match our records.")
      end

      it "denies access when TOTP is enabled" do
        fake_login_admin(other_admin)
        post :totp_setup_form, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-factor authentication is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        post :totp_setup_form, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end

  describe "GET #totp_setup_backup_codes" do
    let(:admin) { create(:admin, otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      get :totp_setup_backup_codes, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :totp_setup_backup_codes, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_otp_secret_if_missing!
      end

      it "shows the backup codes once" do
        fake_login_admin(admin)
        get :totp_setup_backup_codes, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "does not show backup codes when a backup code was already generated" do
        admin.generate_otp_backup_codes!
        admin.save!

        fake_login_admin(admin)
        get :totp_setup_backup_codes, params: { admin_id: admin.login }
        it_redirects_to_with_error(admins_path, "You have already seen your backup codes. For security reasons, they cannot be seen again.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :totp_setup_backup_codes, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        get :totp_setup_backup_codes, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(totp_setup_admin_preferences_path, "Please enable two-factor authentication first.")
      end
    end
  end

  describe "GET #totp_disable" do
    let(:admin) { create(:admin, otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      get :totp_disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      get :totp_disable, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_otp_secret_if_missing!
        admin.generate_otp_backup_codes!
        admin.save!
      end

      it "allows access to their own page when TOTP is enabled" do
        fake_login_admin(admin)
        get :totp_disable, params: { admin_id: admin.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        get :totp_disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-factor authentication is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        get :totp_disable, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end

  describe "POST #totp_disable_form" do
    let(:admin) { create(:admin, password: "correct_password", otp_required_for_login: true) }
    let(:other_admin) { create(:admin) }

    it "denies access to guest users" do
      post :totp_disable_form, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
    end

    it "denies access to non-admins" do
      fake_login
      post :totp_disable_form, params: { admin_id: admin.login }
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    context "when logged in as admin" do
      before do
        admin.generate_otp_secret_if_missing!
        admin.generate_otp_backup_codes!
        admin.save!
      end

      it "allows disabling TOTP" do
        fake_login_admin(admin)
        post :totp_disable_form, params: { admin_id: admin.login, admin: { otp_attempt: admin.current_otp, password: "correct_password" } }
        expect(admin.reload.otp_required_for_login).to be_falsey
        it_redirects_to_with_notice(admin_preferences_path, "Successfully disabled two-factor authentication.")
      end

      it "denies access when TOTP code is wrong" do
        fake_login_admin(admin)
        post :totp_disable_form, params: { admin_id: admin.login, admin: { otp_attempt: "000000", password: "correct_password" } }
        expect(admin.reload.otp_required_for_login).to be_truthy
        it_redirects_to_with_error(totp_disable_admin_preferences_path, "Incorrect authentication code. Your code may have expired.")
      end

      it "denies access when password is wrong" do
        fake_login_admin(admin)
        post :totp_disable_form, params: { admin_id: admin.login, admin: { otp_attempt: admin.current_otp, password: "wrong_password" } }
        expect(admin.reload.otp_required_for_login).to be_truthy
        it_redirects_to_with_error(totp_disable_admin_preferences_path, "The password or admin username you entered doesn't match our records.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_admin(other_admin)
        post :totp_disable_form, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(admins_path, "TOTP two-factor authentication is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_admin(admin)
        post :totp_disable_form, params: { admin_id: other_admin.login }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
  end
end
