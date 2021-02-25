# frozen_string_literal: true

require "spec_helper"

describe Admin::AdminUsersController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows access to index" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #bulk_search" do
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :bulk_search

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows access to access bulk search" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :bulk_search

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :show, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows access to show page" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :show, params: { id: user.login }

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PUT #update" do
    let(:admin) { create(:admin) }
    let(:old_role) { create(:role) }
    let(:role) { create(:role) }
    let(:user) { create(:user, email: "user@example.com", roles: [old_role]) }

    context "when admin does not have correct authorization" do
      before do
        fake_login_admin(admin)
        User.current_user = admin
        admin.update(roles: [])
      end

      it "redirects with error" do
        put :update, params: { id: user.login, user: { roles: [] } }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      before do
        fake_login_admin(admin)
        User.current_user = admin
      end

      context "when admin has superadmin role" do
        before { admin.update(roles: ["superadmin"]) }

        it "allows admins to update all attributes" do
          expect do
            put :update, params: {
              id: user.login,
              user: {
                email: "updated@example.com",
                roles: [role.id.to_s]
              }
            }
          end.to change { user.reload.roles.pluck(:name) }
            .from([old_role.name])
            .to([role.name])
            .and change { user.reload.email }
            .from("user@example.com")
            .to("updated@example.com")

          it_redirects_to_with_notice(root_path, "User was successfully updated.")
        end
      end

      %w[open_doors tag_wrangling].each do |admin_role|
        context "when admin has #{admin_role} role" do
          before { admin.update(roles: [admin_role]) }

          it "prevents admins with #{admin_role} role from updating email" do
            expect do
              put :update, params: { id: user.login, user: { email: "updated@example.com" } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(user.reload.email).not_to eq("updated@example.com")
          end

          it "allows admins with #{admin_role} role to update roles" do
            expect do
              put :update, params: { id: user.login, user: { roles: [role.id.to_s] } }
            end.to change { user.reload.roles.pluck(:name) }
              .from([old_role.name])
              .to([role.name])
              .and avoid_changing { user.reload.email }

            it_redirects_to_with_notice(root_path, "User was successfully updated.")
          end
        end
      end

      %w[support policy_and_abuse].each do |admin_role|
        context "when admin has #{admin_role} role" do
          before { admin.update(roles: [admin_role]) }

          it "prevents admins with #{admin_role} role from updating roles" do
            expect do
              put :update, params: { id: user.login, user: { roles: [role.id.to_s] } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(user.reload.roles).not_to include(role)
          end

          it "allows admins with #{admin_role} role to update email" do
            expect do
              put :update, params: { id: user.login, user: { email: "updated@example.com" } }
            end.to change { user.reload.email }
              .from("user@example.com")
              .to("updated@example.com")
              .and avoid_changing { user.reload.roles.pluck(:name) }

            it_redirects_to_with_notice(root_path, "User was successfully updated.")
          end
        end
      end
    end
  end

  describe "POST #update_status" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :update_status, params: {
          user_login: user.login, admin_action: "suspend", suspend_days: "3", admin_note: "User violated community guidelines"
        }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows admins to suspend user with note" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        post :update_status, params: {
          user_login: user.login, admin_action: "suspend", suspend_days: "3", admin_note: "User violated community guidelines"
        }

        user.reload
        expect(user.suspended).to be_truthy
      end
    end
  end

  describe "GET #confirm_delete_user_creations" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, banned: true) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :confirm_delete_user_creations, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      context "when user is not banned" do
        it "redirects with error" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: false)
          get :confirm_delete_user_creations, params: { id: user.login }

          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end
      end

      context "when user is banned" do
        it "allows admins to access delete user creations page" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: true)
          get :confirm_delete_user_creations, params: { id: user.login }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "POST #destroy_user_creations" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, banned: true) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :confirm_delete_user_creations, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      context "when user is not banned" do
        it "redirects with error" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: false)
          post :confirm_delete_user_creations, params: { id: user.login }

          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end
      end

      context "when user is banned" do
        it "allows admins to destroy user creations" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: true)
          post :confirm_delete_user_creations, params: { id: user.login }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET #troubleshoot" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :troubleshoot, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows admins to troublehoot user account" do
        admin.update(roles: ["support"])
        fake_login_admin(admin)
        get :troubleshoot, params: { id: user.login }

        it_redirects_to_with_notice(root_path, "User account troubleshooting complete.")
      end
    end
  end

  describe "POST #activate" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :activate, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows admins to troublehoot user account" do
        admin.update(roles: ["support"])
        fake_login_admin(admin)
        post :activate, params: { id: user.login }

        it_redirects_to_with_notice(admin_user_path(id: user.login), "User Account Activated")
      end
    end
  end

  describe "POST #send_activation" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, :unconfirmed) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :send_activation, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "succeeds with notice" do
        admin.update(roles: ["support"])
        fake_login_admin(admin)
        post :send_activation, params: { id: user.login }

        it_redirects_to_with_notice(admin_user_path(id: user.login), "Activation email sent")
      end
    end
  end
end
