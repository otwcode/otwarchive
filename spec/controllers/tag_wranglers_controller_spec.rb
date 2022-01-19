# frozen_string_literal: true

require "spec_helper"

describe TagWranglersController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:fandom) { create(:fandom) }

  describe "create" do
    context "when logged in as a wrangler" do
      before do
        wrangler = create(:tag_wrangler)
        fake_login_known_user(wrangler)
      end

      it "errors and redirects to user page when trying to assign a fandom to another user" do
        user2 = create(:user)
        post :create, params: { assignments: { fandom.id => [user2.login] } }
        it_redirects_to_with_error(user_path(@current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end

  describe "destroy" do
    context "when logged in as a wrangler" do
      before do
        wrangler = create(:tag_wrangler)
        fake_login_known_user(wrangler)
      end

      it "errors and redirects to user page when trying to remove a fandom from another user" do
        user2 = create(:user)
        post :destroy, params: { id: user2.login, fandom_id: fandom.id }
        it_redirects_to_with_error(user_path(@current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end
  end
end
