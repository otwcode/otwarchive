# frozen_string_literal: true
require "spec_helper"

describe Admin::UserCreationsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #hide" do    
    let(:admin) { create(:admin) }
    let(:work) { create(:work) }

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :hide, params: { id: work.id, creation_type: 'Work' }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin does have correct authorization' do
      it "allows admin with authorization to hide user_creation" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :hide, params: { id: work.id, creation_type: 'Work', hidden: true }

        it_redirects_to_with_notice(work_path(work), "Item has been hidden.")
        work.reload
        expect(work.hidden_by_admin).to eq(true)
      end

      it "allows admin with authorization to make user_creation visible" do
        work.update(hidden_by_admin: true)
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :hide, params: { id: work.id, creation_type: 'Work', hidden: false }

        it_redirects_to_with_notice(work_path(work), "Item is no longer hidden.")
        work.reload
        expect(work.hidden_by_admin).to eq(false)
      end
    end
  end

  describe "GET #set_spam" do
    let(:admin) { create(:admin) }
    let(:work) { create(:work) }

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :set_spam, params: { id: work.id, creation_type: 'Work', spam: true }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin does have correct authorization' do
      it "allows admin with authorization to mark user_creation as spam" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :set_spam, params: { id: work.id, creation_type: 'Work', spam: true }

        it_redirects_to_with_notice(work_path(work), "Work was marked as spam and hidden.")
        work.reload
        expect(work.spam).to eq(true)
      end

      it "allows admin with authorization to mark user_creation as NOT spam" do
        admin.update(roles: ['policy_and_abuse'])
        work.update(spam: true)
        fake_login_admin(admin)
        get :set_spam, params: { id: work.id, creation_type: 'Work', spam: false }

        it_redirects_to_with_notice(work_path(work), "Work was marked not spam and unhidden.")
        work.reload
        expect(work.spam).to eq(false)
      end
    end
  end

  describe "GET #destroy" do
    let(:admin) { create(:admin) }
    let(:work) { create(:work) }

    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :destroy, params: { id: work.id, creation_type: 'Work' }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context 'when admin does have correct authorization' do
      it "allows admin with authorization to delete user_creation" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :destroy, params: { id: work.id, creation_type: 'Work' }

        it_redirects_to_with_notice(works_path, "Item was successfully deleted.")
      end
    end
  end
end
