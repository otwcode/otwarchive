# frozen_string_literal: true

require "spec_helper"

describe UnsortedTagsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #mass_update" do
    context "when accessing as a guest" do
      before do
        post :mass_update
      end

      it "redirects with an error" do
        it_redirects_to_with_error(
          new_user_session_path,
          "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
        )
      end
    end

    context "when logged in as a non-tag-wrangler user" do
      let(:user) { create(:user) }

      before do
        fake_login_known_user(user)
        post :mass_update
      end

      it "redirects with an error" do
        it_redirects_to_with_error(
          user_path(user),
          "Sorry, you don't have permission to access the page you were trying to reach."
        )
      end
    end

    context "when logged in as an admin with no roles" do
      before do
        fake_login_admin(create(:admin))
        post :mass_update
      end

      it "redirects with an error" do
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin tag_wrangling]).each do |admin_role|
      context "when logged in as a #{admin_role} admin" do
        before do
          fake_login_admin(create(:admin, roles: [admin_role]))
          post :mass_update
        end

        it "redirects with an error" do
          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end
  end
end
