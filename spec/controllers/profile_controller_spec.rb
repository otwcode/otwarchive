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
      before { fake_login_admin(admin) }

      read_roles = %w[superadmin policy_and_abuse]

      context "with no role" do
        let(:admin) { create(:admin, roles: []) }
        
        it "redirects with an error" do
          get :edit, params: { user_id: user.login }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      (Admin::VALID_ROLES - read_roles).each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            get :edit, params: { user_id: user.login }

            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          end
        end
      end

      read_roles.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "assigns user and profile" do
            get :edit, params: { user_id: user.login }
          
            expect(assigns(:user)).to eq(user)
            expect(response).to be_successful            
          end
        end
      end
    end
  end

  describe "POST #update" do
    let(:user) { create(:user) }

    context "as admin" do
      before do 
        fake_login_admin(admin)

        ticket = {
          "departmentId" => ArchiveConfig.ABUSE_ZOHO_DEPARTMENT_ID,
          "status" => "Open",
          "webUrl" => Faker::Internet.url
        }
        allow_any_instance_of(ZohoResourceClient).to receive(:find_ticket).and_return(ticket)
      end

      update_roles = %w[superadmin policy_and_abuse]

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

      context "with no role" do
        let(:admin) { create(:admin, roles: []) }
        
        it "redirects with an error" do
          patch :update, params: params

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      (Admin::VALID_ROLES - update_roles).each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            patch :update, params: params

            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          end
        end
      end

      update_roles.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with a success message" do
            patch :update, params: params
          
            it_redirects_to_with_notice(user_profile_path(user), "Your profile has been successfully updated")            
          end
        end
      end
    end
  end
end
