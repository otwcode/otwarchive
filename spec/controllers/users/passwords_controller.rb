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
      it "sends reset instructions and redirects with a success message" do
        expect do
          post :create, params: { user: { email: user.email } }
        end.to change { ActionMailer::Base.deliveries.count }.by(1)

        it_redirects_to_with_notice(new_user_session_path, "Check your email for instructions on how to reset your password. You may reset your password 2 more times. After that, you will need to wait 12 hours before requesting another reset.")
      end
    end

    context "when resetting password with a correct username" do
      it "redirects with an error" do
        expect do
          post :create, params: { user: { login: user.login } }
        end.to raise_error ActionController::UnpermittedParameters
      end
    end

    context "when resetting password with an incorrect email address" do
      it "redirects with an error" do # TODO: change this to a fake success message
        expect do
          post :create, params: { user: { email: "incorrect-email@example.com" } }
        end.to change { ActionMailer::Base.deliveries.count }.by(0)

        it_redirects_to_with_error(new_user_password_path, "We couldn't find an account with that email address. Please try again.")
      end
    end
  end
end
