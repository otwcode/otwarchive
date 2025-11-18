require "spec_helper"

describe UserInviteRequestsController do
  include RedirectExpectationHelper
  include LoginMacros

  authorized_roles = %w[superadmin policy_and_abuse].freeze

  describe "GET #index" do
    subject { get :index }
    let(:success) do
      expect(response).to render_template("index")
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles

    it "does not allow non-admins to view user invite requests" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end

  describe "PATCH #update" do
    subject { patch :update, params: { requests: { request.id.to_s => "" } } }
    let(:success) do
      it_redirects_to_with_notice(user_invite_requests_path, "Requests were successfully updated.")
    end
    let(:request) { create(:user_invite_requests) }

    it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles

    it "does not allow non-admins to update user invite requests" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end
end
