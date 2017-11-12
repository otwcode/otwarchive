# frozen_string_literal: true

require "spec_helper"

describe GiftsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe 'toggle_rejected' do
    let (:gift) { create(:gift) }

    it 'should reject if no user is logged on' do
      post :toggle_rejected, params: { id: gift.id }
      expect(flash[:error]).to include("Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "should reject if the gift's recipient is not logged on" do
      fake_login
      post :toggle_rejected, params: { id: gift.id }
      expect(flash[:error]).to include("Sorry, you don't have permission to access the page you were trying to reach.")
    end
  end
end
