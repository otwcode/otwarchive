require "spec_helper"

describe Users::TotpController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #new" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, otp_required_for_login: true) }

    it "denies access to guest users" do
      get :new, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login_known_user(other_user)
      get :new, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      it "allows access to their own page when TOTP is disabled" do
        fake_login_known_user(user)
        get :new, params: { user_id: user.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to their own page when TOTP is enabled" do
        fake_login_known_user(other_user)
        get :new, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_preferences_path(other_user), "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        get :new, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #reauthenticate_create" do
    let(:user) { create(:user, password: "correct_password") }
    let(:other_user) { create(:user, otp_required_for_login: true) }

    it "denies access to guest users" do
      post :reauthenticate_create, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login_known_user(other_user)
      post :reauthenticate_create, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      before do
        user.generate_totp_secret_if_missing!
      end

      it "continues to enabling TOTP form when the password is correct" do
        fake_login_known_user(user)
        post :reauthenticate_create, params: { user_id: user.login, password_check: "correct_password" }
        expect(flash).to be_empty
        expect(response).to render_template(:reauthenticate_create)
      end

      it "denies access when password is wrong" do
        fake_login_known_user(user)
        post :reauthenticate_create, params: { user_id: user.login, password_check: "wrong_password" }
        expect(user.reload.totp_enabled?).to be_falsey
        expect(flash[:error]).to eq("Your password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form.")
      end

      it "denies access when TOTP is enabled" do
        fake_login_known_user(other_user)
        post :reauthenticate_create, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_preferences_path(other_user), "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        post :reauthenticate_create, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #create" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user, otp_required_for_login: true) }

    it "denies access to guest users" do
      post :create, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login
      post :create, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      before do
        user.generate_totp_secret_if_missing!
      end

      it "allows enabling TOTP" do
        fake_login_known_user(user)
        post :create, params: { user_id: user.login, totp_attempt: user.current_otp }
        expect(user.reload.totp_enabled?).to be_truthy
        it_redirects_to_with_notice(show_backup_codes_user_totp_path, "Successfully enabled two-step verification; please make note of your backup codes.")
      end

      it "denies access when TOTP code is wrong" do
        fake_login_known_user(user)
        post :create, params: { user_id: user.login, totp_attempt: "000000" }
        expect(user.reload.totp_enabled?).to be_falsey
        expect(flash[:error]).to eq("Incorrect verification code. Your code may have expired, or you may need to set up your authenticator app again.")
      end

      it "denies access when TOTP is enabled" do
        fake_login_known_user(other_user)
        post :create, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_preferences_path(other_user), "TOTP two-step verification is already enabled.")
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        post :create, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "GET #show_backup_codes" do
    let(:user) { create(:user, otp_required_for_login: true) }
    let(:other_user) { create(:user) }

    it "denies access to guest users" do
      get :show_backup_codes, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login
      get :show_backup_codes, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      before do
        user.generate_totp_secret_if_missing!
      end

      it "shows the backup codes once" do
        fake_login_known_user(user)
        get :show_backup_codes, params: { user_id: user.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        get :show_backup_codes, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_known_user(other_user)
        get :show_backup_codes, params: { user_id: other_user.login }
        it_redirects_to_with_error(new_user_totp_path, "Please enable two-step verification first.")
      end
    end
  end

  describe "GET #confirm_disable" do
    let(:user) { create(:user, otp_required_for_login: true) }
    let(:other_user) { create(:user) }

    it "denies access to guest users" do
      get :confirm_disable, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login
      get :confirm_disable, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      before do
        user.generate_totp_secret_if_missing!
        user.generate_otp_backup_codes!
        user.save!
      end

      it "allows access to their own page when TOTP is enabled" do
        fake_login_known_user(user)
        get :confirm_disable, params: { user_id: user.login }
        expect(response).to have_http_status(:success)
      end

      it "denies access when TOTP is disabled" do
        fake_login_known_user(other_user)
        get :confirm_disable, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_preferences_path(other_user),
                                   "TOTP two-step verification is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        get :confirm_disable, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "POST #disable_totp" do
    let(:user) { create(:user, password: "correct_password", otp_required_for_login: true) }
    let(:other_user) { create(:user) }

    it "denies access to guest users" do
      post :disable, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "denies access to other users" do
      fake_login
      post :disable, params: { user_id: user.login }
      it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "when logged in as user" do
      before do
        user.generate_totp_secret_if_missing!
        user.generate_otp_backup_codes!
        user.save!
      end

      it "allows disabling TOTP" do
        fake_login_known_user(user)
        post :disable, params: { user_id: user.login, password_check: "correct_password" }
        expect(user.reload.totp_enabled?).to be_falsey
        it_redirects_to_with_notice(user_preferences_path(user), "Successfully disabled two-step verification.")
      end

      it "denies access when password is wrong" do
        fake_login_known_user(user)
        post :disable, params: { user_id: user.login, password_check: "wrong_password" }
        expect(user.reload.totp_enabled?).to be_truthy
        expect(flash[:error]).to eq("Your password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form.")
      end

      it "denies access when TOTP is disabled" do
        fake_login_known_user(other_user)
        post :disable, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_preferences_path(other_user),
                                   "TOTP two-step verification is already disabled.")
      end

      it "denies access to other's pages" do
        fake_login_known_user(user)
        post :disable, params: { user_id: other_user.login }
        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
