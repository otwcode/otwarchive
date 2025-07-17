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
        end.to change { 
          ActionMailer::Base.deliveries.count
        }.by(1)

        it_redirects_to_with_notice(new_user_session_path, "If your email is in our records, you will receive instructions to reset your password there soon. You may only request a password reset a limited number of times per day.")
      end
    end

    context "when resetting password with a correct username" do
      it "raises an error" do
        expect do
          post :create, params: { user: { login: user.login } }
        end.to raise_error ActionController::UnpermittedParameters
      end
    end

    context "when resetting password with an incorrect email address" do
      it "does not send reset instructions and redirects with a fake success message" do
        expect do
          post :create, params: { user: { email: "incorrect-email@example.com" } }
        end.to change {
          ActionMailer::Base.deliveries.count
        }.by(0)

        it_redirects_to_with_notice(new_user_session_path, "If your email is in our records, you will receive instructions to reset your password there soon. You may only request a password reset a limited number of times per day.")
      end
    end
  end
end
