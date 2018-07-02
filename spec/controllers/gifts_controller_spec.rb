# frozen_string_literal: true

require "spec_helper"

describe GiftsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "toggle_rejected" do
    let(:gift) { create(:gift) }

    # Pending AO3-5445 fix
    xit "errors and redirects to login page if no user is logged on" do
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    # Pending AO3-5445 fix
    xit "errors and redirects to homepage if the gift's recipient is not logged on" do
      fake_login
      post :toggle_rejected, params: { id: gift.id }
      it_redirects_to_with_error(user_path(@current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
    end
  end
end
