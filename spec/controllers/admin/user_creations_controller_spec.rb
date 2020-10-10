# frozen_string_literal: true

require "spec_helper"

describe Admin::UserCreationsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "PUT #hide" do    
    let(:admin) { create(:admin) }

    context "when user creation is a work" do
      let(:work) { create(:work) }

      context "when admin does not have correct authorization" do
        it "redirects with error" do
          admin.update(roles: [])
          fake_login_admin(admin)

          put :hide, params: { id: work.id, creation_type: "Work" }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context "when admin has correct authorization" do
        context "when work is visible and hidden param is true" do
          it "hides work and redirects with notice" do
            admin.update(roles: ["policy_and_abuse"])
            fake_login_admin(admin)
            put :hide, params: { id: work.id, creation_type: "Work", hidden: true }

            it_redirects_to_with_notice(work_path(work), "Item has been hidden.")
            work.reload
            expect(work.hidden_by_admin).to eq(true)
          end
        end

        context "when work is hidden and hidden param is false" do
          it "makes work visible and redirects with notice" do
            work.update(hidden_by_admin: true)
            admin.update(roles: ["policy_and_abuse"])
            fake_login_admin(admin)
            put :hide, params: { id: work.id, creation_type: "Work", hidden: false }

            it_redirects_to_with_notice(work_path(work), "Item is no longer hidden.")
            work.reload
            expect(work.hidden_by_admin).to eq(false)
          end
        end
      end
    end
  end

  describe "PUT #set_spam" do
    let(:admin) { create(:admin) }

    context "when user creation is a work" do
      let(:work) { create(:work) }

      context "when admin does not have correct authorization" do
        it "redirects with error" do
          admin.update(roles: [])
          fake_login_admin(admin)
          put :set_spam, params: { id: work.id, creation_type: "Work", spam: true }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context "when admin has correct authorization" do
        context "when work is not spam and spam param is true" do
          it "marks work as spam, hides it, and redirects with notice" do
            admin.update(roles: ["policy_and_abuse"])
            fake_login_admin(admin)
            put :set_spam, params: { id: work.id, creation_type: "Work", spam: true }

            it_redirects_to_with_notice(work_path(work), "Work was marked as spam and hidden.")
            work.reload
            expect(work.spam).to eq(true)
            expect(work.hidden_by_admin).to eq(true)
          end
        end

        context "when work is spam and spam param is false" do
          it "marks work as not spam, unhides it, and redirects with notice" do
            admin.update(roles: ["policy_and_abuse"])
            work.update(spam: true)
            fake_login_admin(admin)
            put :set_spam, params: { id: work.id, creation_type: "Work", spam: false }

            it_redirects_to_with_notice(work_path(work), "Work was marked not spam and unhidden.")
            work.reload
            expect(work.spam).to eq(false)
            expect(work.hidden_by_admin).to eq(false)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:admin) { create(:admin) }

    context "when user creation is a work" do
      let(:work) { create(:work) }

      context "when admin does not have correct authorization" do
        it "redirects with error" do
          admin.update(roles: [])
          fake_login_admin(admin)
          delete :destroy, params: { id: work.id, creation_type: "Work" }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context "when admin has correct authorization" do
        it "destroys item and redirects with notice" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          delete :destroy, params: { id: work.id, creation_type: "Work" }

          it_redirects_to_with_notice(works_path, "Item was successfully deleted.")
          expect { work.reload }.to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
