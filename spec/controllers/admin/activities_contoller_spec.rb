# frozen_string_literal: true

require "spec_helper"

describe Admin::ActivitiesController do
  include LoginMacros

  let!(:admin) { FactoryGirl.create(:admin) }
  let!(:admin_activity) { FactoryGirl.create(:admin_activity, admin: admin, target: FactoryGirl.create(:work)) }

  before do
    fake_login_admin(admin)
  end

  render_views

  describe "index" do
    it "contains the admin's login" do
      get :index
      expect(response.body).to include(admin.login)
    end

    context "when admin is deleted" do
      it "contains 'Admin deleted'" do
        allow_any_instance_of(AdminActivity).to receive(:admin).and_return(nil)
        get :index
        expect(response.body).to include("Admin deleted")
      end
    end
  end

  describe "show" do
    it "contains the admin's login" do
      get :show, params: { id: admin_activity.id }
      expect(response.body).to include(admin.login)
    end

    context "when admin is deleted" do
      it "contains 'Admin deleted'" do
        allow_any_instance_of(AdminActivity).to receive(:admin).and_return(nil)
        get :show, params: { id: admin_activity.id }
        expect(response.body).to include("Admin deleted")
      end
    end
  end
end
