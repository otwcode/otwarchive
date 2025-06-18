# frozen_string_literal: true

require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #navigate" do
    context "denies access for work that isn't visible to user" do
      subject { get :navigate, params: { id: work.id } }
      let(:success) { expect(response).to render_template("navigate") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end
  end
end
