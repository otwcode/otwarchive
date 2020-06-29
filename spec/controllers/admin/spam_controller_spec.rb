# frozen_string_literal: true

require "spec_helper"

describe Admin::SpamController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do    
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "admin must be logged in" do
        fake_login

        get :index, params: { reviewed: false, approved: false }
        it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
      end
    end

    context "when admin does have correct authorization" do
      it "allows admin to view index page" do
        fake_login_admin(admin)
        get :index, params: { reviewed: false, approved: false }
        expect(response).to render_template("index")
      end
    end
  end

  describe "GET #bulk_update" do
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "denies non-admin access" do
        fake_login
        get :bulk_update, params: { ham: true }
        it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
      end
    end

    context "when admin does have correct authorization" do
      it "allows admin with authorization to mark user_creation as spam" do
        FactoryBot.create_list(:moderated_work, 3)
        moderated_work = ModeratedWork.first
        fake_login_admin(admin)
        get :bulk_update, params: { spam: ModeratedWork.all.map(&:id) }

        it_redirects_to_with_notice(admin_spam_index_path, "Works were successfully updated")
        moderated_work.reload
        expect(moderated_work.reviewed).to eq(true)
      end
    end
  end
end
