require "spec_helper"

describe PotentialMatchesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:collection) { create(:collection, challenge: create(:gift_exchange)) }

  describe "index" do
    authorized_roles = %w[support policy_and_abuse superadmin].freeze

    subject { get :index, params: { collection_id: collection.name } }

    let(:success) do
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles
  end
end
