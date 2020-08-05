# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let!(:work) { create(:work, authors: [user.default_pseud]) } #, posted: true

  context "preview_tags" do
    it "should render preview tags" do
      fake_login_known_user(user)

      get :preview_tags, params: { id: work }
      expect(response).to render_template "preview_tags"
    end
  end
end
