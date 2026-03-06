require "spec_helper"

describe PotentialMatchesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:collection) { create(:collection, challenge: create(:gift_exchange)) }

  describe "index" do
    %i[support_admin policy_and_abuse_admin superadmin].each do |admin_factory|
      it "allows #{admin_factory} to view potential matches" do
        fake_login_admin(create(admin_factory))

        get :index, params: { collection_id: collection.name }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end
    end

    it "does not allow admins with other roles to view potential matches" do
      fake_login_admin(create(:tag_wrangling_admin))

      get :index, params: { collection_id: collection.name }

      it_redirects_to_user_login_with_error
    end
  end
end
