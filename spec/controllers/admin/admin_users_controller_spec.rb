# frozen_string_literal: true
require "spec_helper"

describe Admin::AdminUsersController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let(:admin) { create(:admin) }
 
    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin has correct authorization' do
      it "allows admins to access index" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #bulk_search" do
    let(:admin) { create(:admin) }
 
    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :bulk_search
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin has correct authorization' do
      it "allows admins to access bulk search" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :bulk_search
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :show, params: { id: user.login }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin has correct authorization' do
      it "allows admins to access show page" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :show, params: { id: user.login }
        expect(response).to have_http_status(:success)
      end
    end

    describe "PUT #update" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user) }
  
      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :update, params: { id: user.login, user: { roles: [] } }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
  
      context 'when admin has correct authorization' do
        role = FactoryBot.create(:role)

        it "allows admins to update user account" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          get :update, params: { id: user.login, user: { roles: [role.id.to_s] } }
          expect(user.roles.include?(role)).to be_truthy
        end
      end
    end

    describe "POST #update_status" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user) }
  
      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          post :update_status, params: {
            user_login: user.login, user_login: user.login, admin_action: 'suspend', suspend_days: '3', admin_note: 'User violated community guidelines'
          }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
  
      context 'when admin has correct authorization' do
        it "allows admins to update user status" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          post :update_status, params: {
            user_login: user.login, user_login: user.login, admin_action: 'suspend', suspend_days: '3', admin_note: 'User violated community guidelines'
          }

          user.reload
          expect(user.suspended).to be_truthy
        end
      end
    end

    describe "GET #confirm_delete_user_creations" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user, banned: true) }

      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :confirm_delete_user_creations, params: { id: user.login }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin has correct authorization' do
        it "returns error when user is not banned" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          user.update(banned: false)
          get :confirm_delete_user_creations, params: { id: user.login }
          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end

        it "allows admins to access delete user creations page" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          user.update(banned: true)
          get :confirm_delete_user_creations, params: { id: user.login }
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe "GET #destroy_user_creations" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user, banned: true) }

      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          delete :confirm_delete_user_creations, params: { id: user.login }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin has correct authorization' do
        it "returns error when user is not banned" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          user.update(banned: false)
          delete :confirm_delete_user_creations, params: { id: user.login }
          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end

        it "allows admins to destroy user creations" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          user.update(banned: true)
          delete :confirm_delete_user_creations, params: { id: user.login }
          expect(response).to have_http_status(:success)
        end
      end

    end

    describe "GET #troubleshoot" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user) }

      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :troubleshoot, params: { id: user.login }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin has correct authorization' do
        it "allows admins to troublehoot user account" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          get :troubleshoot, params: { id: user.login }
          it_redirects_to_with_notice(root_path, "User account troubleshooting complete.")
        end
      end
    end

    describe "GET #activate" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user) }

      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :activate, params: { id: user.login }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin to activate user account' do
        it "allows admins to troublehoot user account" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          get :activate, params: { id: user.login }
          it_redirects_to_with_notice(admin_user_path(id: user.login), "User Account Activated")
        end
      end
    end

    describe "GET #send_activation" do
      let(:admin) { create(:admin) }
      let(:user) { create(:user) }

      context 'when admin does not have correct authorization' do
        it "denies random admin access" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :send_activation, params: { id: user.login }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context 'when admin to activate user account' do
        it "allows admins to troublehoot user account" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)
          get :send_activation, params: { id: user.login }
          it_redirects_to_with_notice(admin_user_path(id: user.login), "Activation email sent")
        end 
      end
    end
  end
end
