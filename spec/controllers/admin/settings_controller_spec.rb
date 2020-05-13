# frozen_string_literal: true
require "spec_helper"

describe Admin::SettingsController do
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

  describe "PUT #update" do
    let(:admin) { create(:admin) }
    let(:setting) { create(:admin_setting, last_updated_by: admin.id) }

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        put :update, params: { id: setting.id, admin_setting: { last_updated_by: admin.login } }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin has correct authorization' do
      context 'when admin has superadmin role' do
        it "allows superadmins to update all settings" do
          admin.update(roles: ['superadmin'])
          fake_login_admin(admin)

          put :update, params: {
            id: setting.id,
            admin_setting: {
              account_creation_enabled: "1",
              creation_requires_invite: "1",
              request_invite_enabled: "0",
              invite_from_queue_enabled: "1",
              invite_from_queue_number: "10",
              invite_from_queue_frequency: "7",
              days_to_purge_unactivated: "7",
              disable_support_form: "1",
              disabled_support_form_text: "Disable support",
              suspend_filter_counts: "0",
              tag_wrangling_off: "0",
              downloads_enabled: "1",
              enable_test_caching: "0",
              cache_expiration: "10",
              hide_spam: "1"
            } 
          }

          it_redirects_to_with_notice(admin_settings_path, "Archive settings were successfully updated.")
        end
      end

      context 'when admin has policy_and_abuse role' do
        it "prohibits admins with policy_and_abuse role to update forbidden settings" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)

          put :update, params: {
            id: setting.id,
            admin_setting: {
              suspend_filter_counts: "0",
              tag_wrangling_off: "0",
              downloads_enabled: "1",
              enable_test_caching: "0",
              cache_expiration: "10",
              hide_spam: "1"
            } 
          }

          expect(response).to render_template('index')
          expect(flash[:error]).to(
            include("You are not permitted to change the following settings: Suspend filter counts, Enable test caching, Cache expiration, Tag wrangling off, Downloads enabled")
          )
        end

        it "allows admins with policy_and_abuse role to update spam setting" do
          admin.update(roles: ['policy_and_abuse'])
          fake_login_admin(admin)

          put :update, params: { id: setting.id, admin_setting: { hide_spam: "1" } }

          it_redirects_to_with_notice(admin_settings_path, "Archive settings were successfully updated.")
        end
      end

      context 'when admin has support role' do
        it "prohibits admins with support role to update forbidden settings" do
          admin.update(roles: ['support'])
          fake_login_admin(admin)

          put :update, params: {
            id: setting.id,
            admin_setting: {
              disable_support_form: "1",
              disabled_support_form_text: "Disable support",
              tag_wrangling_off: "0",
              downloads_enabled: "1",
              enable_test_caching: "0",
              hide_spam: "1"
            } 
          }

          expect(response).to render_template('index')
          expect(flash[:error]).to(
            include("You are not permitted to change the following settings: Enable test caching, Tag wrangling off, Downloads enabled, Hide spam")
          )
        end

        it "allows admins with support role to update spam setting" do
          admin.update(roles: ['support'])
          fake_login_admin(admin)

          put :update, params: {
            id: setting.id,
            admin_setting: {
              disable_support_form: "1",
              disabled_support_form_text: "Disable support"
            }
          }

          it_redirects_to_with_notice(admin_settings_path, "Archive settings were successfully updated.")
        end
      end

      context 'when admin has tag_wrangling role' do
        it "prohibits admins with tag_wrangling role to update forbidden settings" do
          admin.update(roles: ['tag_wrangling'])
          fake_login_admin(admin)

          put :update, params: {
            id: setting.id,
            admin_setting: {
              disable_support_form: "1",
              disabled_support_form_text: "Disable support",
              tag_wrangling_off: "0",
              downloads_enabled: "1",
              enable_test_caching: "0",
              hide_spam: "1"
            } 
          }

          expect(response).to render_template('index')
          expect(flash[:error]).to(
            include("You are not permitted to change the following settings: Enable test caching, Downloads enabled, Hide spam, Disable support form, Disabled support form text")
          )
        end

        it "allows admins with policy_and_abuse role to update spam setting" do
          admin.update(roles: ['tag_wrangling'])
          fake_login_admin(admin)

          put :update, params: { id: setting.id, admin_setting: { tag_wrangling_off: "0" } }
          it_redirects_to_with_notice(admin_settings_path, "Archive settings were successfully updated.")
        end
      end
    end
  end
end
