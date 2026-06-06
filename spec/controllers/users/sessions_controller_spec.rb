require "spec_helper"

describe Users::SessionsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "POST #create (TOTP two-factor)" do
    let(:user) { create(:user, password: "testpassword") }
    let(:backup_codes) do
      user.generate_totp_secret_if_missing!
      user.enable_totp!
      codes = user.generate_otp_backup_codes!
      user.save!
      codes
    end

    before do
      backup_codes
      session[:otp_user_id] = user.id
    end

    context "when a valid backup code is submitted" do
      it "disables two-factor authentication for the user" do
        post :create, params: { totp_attempt: backup_codes.first }
        expect(user.reload.totp_enabled?).to be_falsey
      end

      it "clears the otp_secret and otp_backup_codes" do
        post :create, params: { totp_attempt: backup_codes.first }
        expect(user.reload.otp_secret).to be_nil
        expect(user.reload.otp_backup_codes).to be_blank
      end

      it "redirects to user preferences with a notice" do
        post :create, params: { totp_attempt: backup_codes.first }
        it_redirects_to_with_notice(
          user_preferences_path(user),
          "Successfully logged in with your backup code. Two-step verification has been disabled. Please set up two-step verification again to secure your account."
        )
      end

      it "signs the user in" do
        post :create, params: { totp_attempt: backup_codes.first }
        expect(controller.user_signed_in?).to be_truthy
      end
    end

    context "when a valid TOTP code is submitted" do
      it "does not disable two-factor authentication" do
        post :create, params: { totp_attempt: user.current_otp }
        expect(user.reload.totp_enabled?).to be_truthy
      end

      it "redirects to the root path with the signed-in notice" do
        post :create, params: { totp_attempt: user.current_otp }
        it_redirects_to_with_notice(root_path, "Successfully logged in.")
      end
    end

    context "when an invalid code is submitted" do
      it "does not disable two-factor authentication" do
        post :create, params: { totp_attempt: "000000" }
        expect(user.reload.totp_enabled?).to be_truthy
      end

      it "renders the TOTP form with an error" do
        post :create, params: { totp_attempt: "000000" }
        expect(response).to render_template("users/sessions/totp")
        expect(flash[:error]).to eq("Incorrect two-step verification code. If you no longer have access to your authenticator app, you can enter one of your backup codes instead.")
      end
    end
  end
end
