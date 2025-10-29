require "spec_helper"

describe ProfileController do
  include RedirectExpectationHelper
  include LoginMacros

  describe "show" do
    let(:user) { create(:user) }

    it "redirects and shows an error message for a non existent user" do
      get :show, params: { user_id: 999_999_999_999 }

      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, there's no user by that name."
    end

    it "creates a new profile if one does not exist" do
      user.profile.destroy
      user.reload

      get :show, params: { user_id: user }

      expect(user.profile).not_to be_nil
    end
  end

  describe "GET #edit" do
    let(:user) { create(:user) }

    context "as admin" do
      subject { get :edit, params: { user_id: user.login } }

      let(:success) do
        expect(assigns(:user)).to eq(user)
        expect(response).to be_successful    
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: %w[superadmin policy_and_abuse]
    end
  end

  describe "PATCH #update" do
    let(:user) { create(:user) }

    context "as admin" do
      before do 
        ticket = {
          "departmentId" => ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID,
          "status" => "Open",
          "webUrl" => Faker::Internet.url
        }
        allow_any_instance_of(ZohoResourceClient).to receive(:find_ticket).and_return(ticket)
      end

      let(:params) do
        {
          user_id: user.login,
          profile: {
            title: "Title",
            about_me: "About Me",
            ticket_number: "123456"
          }
        }
      end

      subject { patch :update, params: params }

      let(:success) do
        it_redirects_to_with_notice(user_profile_path(user), "Your profile has been successfully updated")
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: %w[superadmin policy_and_abuse]
    end
  end
end
