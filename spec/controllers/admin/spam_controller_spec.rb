# frozen_string_literal: true

require "spec_helper"

describe Admin::SpamController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let(:admin) { create(:admin) }

    context "when logged in as user" do
      it "redirects with notice" do
        fake_login
        get :index

        it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
      end
    end

    context "when logged in as admin without correct authorization" do
      xit "redirects with notice" do
        fake_login_admin(admin)
        get :index

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as admin" do
      it "renders index template" do
        fake_login_admin(admin)
 
        get :index
        expect(response).to render_template(:index)
      end
    end

    context "when spam exists" do
      it "redirects to post with notice" do
        spam_work = create(:work, spam: true)
        fake_login_admin(admin)
        get :index
        expect(response).to render_template(:index)
        expect(assigns[:works]).to include(spam_work.moderated_work)
      end
    end

    context "when spam has been deleted" do
      it "fails horribly in manual testing but works fine here" do
        deleted_work = create(:work, spam: true) 
        deleted_work.destroy
        fake_login_admin(admin)
        get :index
        expect(response).to render_template(:index)
        expect(assigns[:works]).not_to include(deleted_work.moderated_work)
      end
    end
  end

  describe "POST #bulk_update" do
    let(:admin) { create(:admin) }

    context "when logged in as user" do
      it "redirects with notice" do
        fake_login
        post :bulk_update, params: { ham: true }

        it_redirects_to_with_notice(root_url, "I'm sorry, only an admin can look at that area")
      end
    end

    context "when logged in as admin without correct authorization" do
      xit "redirects with notice" do
        fake_login_admin(admin)
        post :bulk_update, params: { ham: true }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as admin" do
      it "marks moderated works as reviewed, marks works as spam, hides the works, and redirects with notice" do
        FactoryBot.create_list(:moderated_work, 3)
        fake_login_admin(admin)
        post :bulk_update, params: { spam: ModeratedWork.all.map(&:id) }

        it_redirects_to_with_notice(admin_spam_index_path, "Works were successfully updated")
        ModeratedWork.all.each do |moderated_work|
          moderated_work.reload
          expect(moderated_work.reviewed).to eq(true)
          expect(moderated_work.work.spam).to eq(true)
          expect(moderated_work.work.hidden_by_admin).to eq(true)
        end
      end
    end
  end
end
