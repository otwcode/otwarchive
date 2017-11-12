# frozen_string_literal: true

require "spec_helper"

describe GiftsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe 'toggle_rejected'
    let (:gift) { create(:gift) }

    it 'should reject if no user is logged on' do
      post :toggle_rejected, params: { id: gift.id }
      expect(flash[:error]).to include("Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end
end