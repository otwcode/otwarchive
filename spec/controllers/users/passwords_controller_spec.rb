require "spec_helper"

describe Users::PasswordsController do
  include RedirectExpectationHelper

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #edit" do
    it "redirects with an error when not providing a token" do
      get :edit

      it_redirects_to_with_error(
        new_user_password_path,
        "This password reset link is invalid or incomplete. Please check your email for the correct link or request a new password reset."
      )
    end

    it "redirects with an error when providing a blank token" do
      get :edit, params: { reset_password_token: "" }

      it_redirects_to_with_error(
        new_user_password_path,
        "This password reset link is invalid or incomplete. Please check your email for the correct link or request a new password reset."
      )
    end

    it "redirects with an error when providing an invalid token" do
      get :edit, params: { reset_password_token: "keysmash" }

      it_redirects_to_with_error(
        new_user_password_path,
        "This password reset link is invalid or expired. Please check your email for the most recent password reset link. If it has been more than #{ArchiveConfig.PASSWORD_RESET_COOLDOWN_HOURS} hours, you can request a new password reset."
      )
    end
  end
end
