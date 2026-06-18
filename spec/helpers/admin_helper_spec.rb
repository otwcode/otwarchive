# frozen_string_literal: true

require "spec_helper"

describe AdminHelper do
  let!(:admin) { FactoryBot.create(:admin) }
  let!(:admin_activity) { FactoryBot.create(:admin_activity, admin: admin) }

  describe "admin activity login string" do
    it "contains the admin's login" do
      result = admin_activity_login_string(admin_activity)
      expect(result).to include(admin.login)
    end

    context "when admin is deleted" do
      it "contains 'Admin deleted'" do
        allow(admin_activity).to receive(:admin).and_return(nil)
        result = admin_activity_login_string(admin_activity)
        expect(result).to include("Admin deleted")
      end
    end
  end

  describe "admin activity summary" do
    it "renders comment settings summaries as HTML" do
      admin_activity.action = "edit comment settings"
      admin_activity.summary = "<p>Old comment setting: Only registered users can comment</p>"

      expect(admin_activity_summary(admin_activity)).to eq(
        "<p>Old comment setting: Only registered users can comment</p>"
      )
    end
  end
end
