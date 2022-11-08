# frozen_string_literal: true

require "spec_helper"

describe GiftsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "toggle_rejected" do
    let(:gift) { create(:gift) }

    it "errors and redirects to login page if no user is logged on" do
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "errors and redirects to homepage if the gift's recipient is not logged on" do
      fake_login
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end
  end

  describe "index" do
    context "without user_id or recipient parameter" do
      it "redirects to the homepage with an error" do
        get :index
        it_redirects_to_with_error(root_path, "Whose gifts did you want to see?")
      end
    end

    context "with recipient parameter" do
      context "when recipient does not have an account" do
        it "does not redirect or error" do
          get :index, params: { recipient: "nobody" }
          expect(response).to render_template(:index)
        end
      end
    end
  end
end
