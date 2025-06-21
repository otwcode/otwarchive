require "spec_helper"

describe Admin::PasswordsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    @request.env["devise.mapping"] = Devise.mappings[:admin]
  end

  describe "GET #edit" do
    let(:admin) { create(:admin) }
    let(:reset_token) { admin.send_reset_password_instructions }

    context "when the admin's TOTP is enabled" do
      before do
        admin.update(otp_required_for_login: true)
        get :edit, params: { reset_password_token: reset_token }
      end

      it "sets @totp_required to true" do
        expect(assigns(:totp_required)).to eq(true)
      end
    end

    context "when the admin's TOTP is disabled" do
      before do
        admin.update(otp_required_for_login: false)
        get :edit, params: { reset_password_token: reset_token }
      end

      it "sets @totp_required to false" do
        expect(assigns(:totp_required)).to eq(false)
      end
    end
  end

  describe "PUT #update" do
    let(:admin) { create(:admin, otp_required_for_login: true) }
    let(:reset_token) { admin.send_reset_password_instructions }

    before do
      admin.generate_otp_secret_if_missing!
    end

    context "with an invalid code" do
      before do
        put :update, params: {
          admin: {
            reset_password_token: reset_token,
            password: "newpassword",
            password_confirmation: "newpassword",
            otp_attempt: "000000"
          }
        }
      end

      it "rejects the request" do
        it_redirects_to_with_error(edit_admin_password_path(reset_password_token: reset_token), "Incorrect two-factor authentication code. If you no longer have access to your authenticator app, you can enter one of your backup codes instead.")
      end
    end

    context "with valid OTP" do
      before do
        put :update, params: {
          admin: {
            reset_password_token: reset_token,
            password: "newpassword",
            password_confirmation: "newpassword",
            otp_attempt: admin.current_otp
          }
        }
      end

      it "changes the password" do
        it_redirects_to_with_notice(admins_path, "Your password has been changed successfully. You are now signed in.")
      end
    end

    context "when TOTP 2FA is disabled" do
      before do
        admin.update(otp_required_for_login: false)

        put :update, params: {
          admin: {
            reset_password_token: reset_token,
            password: "newpassword",
            password_confirmation: "newpassword",
            otp_attempt: ""
          }
        }
      end

      it "changes the password" do
        it_redirects_to_with_notice(admins_path, "Your password has been changed successfully. You are now signed in.")
      end
    end
  end
end
