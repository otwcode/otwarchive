require "spec_helper"

describe Users::PasswordsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "create" do
    let(:user) { create(:user) }

    context "when resetting password with a correct email address" do
      it "sends reset instructions and shows a success message" do
        expect do        
          post :create, params: { user: { email: user.email } }
        end.to send_email(
          from: 'do-not-reply@example.org',
          to: user.email,
          subject: '[AO3] Reset your password'
        )

        it_redirects_to_with_notice(new_user_password_path, "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password.")
      end
    end

    context "when resetting password with a correct username" do
      it "does not send reset instructions and shows an error" do
        expect do
          post :create, params: { user: { login: user.login } }
        end.to_not send_email

        it_redirects_to_with_error(new_user_password_path, "You must enter your email address.")
      end
    end

    context "when resetting password with an incorrect email address" do
      it "does not send reset instructions and shows a fake success message" do
        expect do
          post :create, params: { user: { email: "incorrect-email@example.com" } }
        end.to_not send_email

        it_redirects_to_with_notice(new_user_password_path, "If the email address you entered is currently associated with an AO3 account, you should receive an email with instructions to reset your password.")
      end
    end
  end
end
