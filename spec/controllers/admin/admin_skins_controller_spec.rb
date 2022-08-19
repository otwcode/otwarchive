# frozen_string_literal: true

require "spec_helper"

describe Admin::SkinsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }

  describe "GET #index" do
    context "when admin does not have correct authorization" do
      context "when admin has no role" do
        it "redirects with error when admin has no role" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :index

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      %w[board communications docs open_doors policy_and_abuse support tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :index

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    context "when admin is authorized with the superadmin role" do
      it "renders index template" do
        admin.update(roles: ["superadmin"])
        fake_login_admin(admin)
        get :index

        expect(response).to render_template(:index)
      end
    end
  end

  describe "GET #index_approved" do
    context "when admin does not have correct authorization" do
      it "redirects with error when admin has no role" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index_approved

        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end

      %w[board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :index_approved

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[superadmin support].each do |role|
      context "when admin is authorized with the #{role} role" do
        it "renders index_approved template" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_approved

          expect(response).to render_template(:index_approved)
        end
      end
    end
  end

  describe "GET #index_rejected" do
    context "when admin does not have correct authorization" do
      it "redirects with error when admin has no role" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index_rejected

        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end

      %w[board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :index_rejected

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[superadmin support].each do |role|
      context "when admin is authorized with the #{role} role" do
        it "renders index_rejected template" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_rejected

          expect(response).to render_template(:index_rejected)
        end
      end
    end
  end
end
