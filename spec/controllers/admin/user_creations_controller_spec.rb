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
          admin.update!(roles: [])
          fake_login_admin(admin)

          put :hide, params: { id: work.id, creation_type: "Work" }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context "when admin has correct authorization" do
        context "when work is visible and hidden param is true" do
          it "hides work and redirects with notice" do
            admin.update!(roles: ["policy_and_abuse"])
            fake_login_admin(admin)
            put :hide, params: { id: work.id, creation_type: "Work", hidden: true }

            it_redirects_to_with_notice(work_path(work), "Item has been hidden.")
            work.reload
            expect(work.hidden_by_admin).to eq(true)
          end
        end

        context "when work is hidden and hidden param is false" do
          it "makes work visible and redirects with notice" do
            work.update!(hidden_by_admin: true)
            admin.update!(roles: ["policy_and_abuse"])
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
          admin.update!(roles: [])
          fake_login_admin(admin)
          put :set_spam, params: { id: work.id, creation_type: "Work", spam: true }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      context "when admin has correct authorization" do
        context "when work is not spam and spam param is true" do
          it "marks work as spam, hides it, and redirects with notice" do
            admin.update!(roles: ["policy_and_abuse"])
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
            admin.update!(roles: ["policy_and_abuse"])
            work.update!(spam: true)
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

    before { fake_login_admin(admin) }

    shared_examples "unauthorized admin cannot delete works" do
      let(:work) { create(:work) }

      it "redirects with error" do
        delete :destroy, params: { id: work.id, creation_type: "Work" }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "authorized admin can delete works" do
      let(:work) { create(:work) }

      it "destroys the work and redirects with notice" do
        delete :destroy, params: { id: work.id, creation_type: "Work" }
        it_redirects_to_with_notice(works_path, "Item was successfully deleted.")
        expect { work.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    shared_examples "unauthorized admin cannot delete bookmarks" do
      let(:bookmark) { create(:bookmark) }

      it "redirects with error" do
        delete :destroy, params: { id: bookmark.id, creation_type: "Bookmark" }
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "authorized admin can delete bookmarks" do
      let(:bookmark) { create(:bookmark) }

      it "destroys the bookmark and redirects with notice" do
        delete :destroy, params: { id: bookmark.id, creation_type: "Bookmark" }
        it_redirects_to_with_notice(bookmarks_path, "Item was successfully deleted.")
        expect { bookmark.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "when admin does not have correct authorization" do
      before { admin.update!(roles: []) }

      it_behaves_like "unauthorized admin cannot delete works"
      it_behaves_like "unauthorized admin cannot delete bookmarks"
    end

    %w[superadmin policy_and_abuse].each do |role|
      context "when admin has #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it_behaves_like "authorized admin can delete works"
        it_behaves_like "authorized admin can delete bookmarks"
      end
    end

    context "when admin has support role" do
      let(:admin) { create(:support_admin) }

      it_behaves_like "authorized admin can delete works"
      it_behaves_like "unauthorized admin cannot delete bookmarks"
    end
  end

  shared_examples "an action only authorized admins can access" do |authorized_roles:|
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    authorized_roles.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  authorized_roles = %w[superadmin policy_and_abuse support].freeze

  describe "GET #confirm_remove_pseud" do
    subject { get :confirm_remove_pseud, params: { id: work.id } }
    let(:work) do
      work = create(:work)
      create(:user, login: "orphan_account")
      Creatorship.orphan(work.pseuds, [work], false)
      work
    end
    let(:success) do
      expect(response).to render_template(:confirm_remove_pseud)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles

    context "when logged in as user" do
      it "redirects with notice" do
        fake_login
        subject
        it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
      end
    end

    context "for a non-orphaned work" do
      let(:work) { create(:work) }

      before do
        fake_login_admin(create(:superadmin))
      end

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(work_path(work), "Sorry, this action is only available for works by orphan_account pseuds.")
      end
    end
  end

  describe "PUT #remove_pseud" do
    subject { put :remove_pseud, params: { id: work.id } }
    let(:user) { create(:user, login: "Leaver") }
    let!(:orphan_account) { create(:user, login: "orphan_account") }
    let!(:orphan_pseud) { create(:pseud, name: "Leaver", user: orphan_account) }
    let(:work) do
      work = create(:work, authors: [user.default_pseud])
      Creatorship.orphan([user.default_pseud], [work], false)
      work
    end
    let(:success) do
      it_redirects_to_with_notice(work_path(work), "Successfully removed pseud Leaver (orphan_account) from this work.")
      expect(work.reload.pseuds).to include(orphan_account.default_pseud)
      expect(work.pseuds).not_to include(orphan_pseud)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles

    context "when logged in as user" do
      it "redirects with notice" do
        fake_login
        subject
        it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
      end
    end

    context "for a work with multiple orphan pseuds" do
      let!(:orphaneer_orphan_pseud) { create(:pseud, name: "orphaneer", user: orphan_account) }

      let(:work) do
        orphaneer = create(:user, login: "orphaneer")
        work = create(:work, authors: [user.default_pseud, orphaneer.default_pseud])
        Creatorship.orphan([user.default_pseud, orphaneer.default_pseud], [work], false)
        work
      end

      before do
        fake_login_admin(create(:superadmin))
      end

      context "without a pseuds parameter" do
        it "redirects with an error" do
          subject
          it_redirects_to_with_error(work_path(work), "You must select which orphan_account pseud to remove.")
          expect(work.reload.pseuds).not_to include(orphan_account.default_pseud)
        end
      end

      context "with a orphan_account pseuds parameter" do
        subject { put :remove_pseud, params: { id: work.id, pseuds: [orphan_pseud.id] } }

        it "redirects removes only that pseud" do
          subject
          it_redirects_to_with_notice(work_path(work), "Successfully removed pseud Leaver (orphan_account) from this work.")
          expect(work.reload.pseuds).to include(orphan_account.default_pseud)
          expect(work.pseuds).not_to include(orphan_pseud)
          expect(work.reload.pseuds).to include(orphaneer_orphan_pseud)
        end
      end

      context "with a pseud parameter by a normal user" do
        subject { put :remove_pseud, params: { id: work.id, pseuds: [user.default_pseud.id] } }

        it "does not modify the work" do
          expect do
            subject
          end.not_to change { work.pseuds }
          it_redirects_to_with_notice(work_path(work), "Successfully removed pseuds  from this work.")
        end
      end
    end
  end
end
