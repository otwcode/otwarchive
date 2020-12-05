require "spec_helper"

describe "Admin settings" do
  let(:admin) { create(:admin) }

  describe "#index" do
    it "denies random access" do
      get admin_settings_path
      expect(response).to redirect_to root_url
    end

    it "denies random admin access" do
      admin.update(roles: [])
      sign_in admin
      get admin_settings_path
      expect(response).to redirect_to root_url
    end

    it "allows access to authorized admins" do
      admin.update(roles: ["tag_wrangling"])
      sign_in admin
      get admin_settings_path
      expect(response).to render_template(:index)
    end
  end
end
