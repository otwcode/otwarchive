# frozen_string_literal: true

require "spec_helper"

describe Admin::AdminUsersController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows access to index" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :index

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #bulk_search" do
    let(:admin) { create(:admin) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :bulk_search

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows access to access bulk search" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :bulk_search

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET #show" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :show, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "if user exists, allows access to show page" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        get :show, params: { id: user.login }

        expect(response).to have_http_status(:success)
      end

      it "if user does not exists, raises a 404" do
        admin.update(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
        params = { id: "not_existing_id" }

        expect { get :show, params: params }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "PUT #update" do
    let(:admin) { create(:admin) }
    let(:old_role) { create(:role) }
    let(:role) { create(:role) }
    let(:user) { create(:user, email: "user@example.com", roles: [old_role]) }

    context "when admin does not have correct authorization" do
      before do
        fake_login_admin(admin)
        admin.update(roles: [])
      end

      it "redirects with error" do
        put :update, params: { id: user.login, user: { roles: [] } }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      before { fake_login_admin(admin) }

      %w[policy_and_abuse superadmin].each do |admin_role|
        context "when admin has #{admin_role} role" do
          before { admin.update(roles: [admin_role]) }

          it "allows admins to update all attributes" do
            expect do
              put :update, params: {
                id: user.login,
                user: {
                  email: "updated@example.com",
                  roles: [role.id.to_s]
                }
              }
            end.to change { user.reload.roles.pluck(:name) }
              .from([old_role.name])
              .to([role.name])
              .and change { user.reload.email }
              .from("user@example.com")
              .to("updated@example.com")

            it_redirects_to_with_notice(root_path, "User was successfully updated.")
          end
        end
      end

      %w[open_doors tag_wrangling].each do |admin_role|
        context "when admin has #{admin_role} role" do
          before { admin.update(roles: [admin_role]) }

          it "prevents admins with #{admin_role} role from updating email" do
            expect do
              put :update, params: { id: user.login, user: { email: "updated@example.com" } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(user.reload.email).not_to eq("updated@example.com")
          end

          it "allows admins with #{admin_role} role to update roles" do
            expect do
              put :update, params: { id: user.login, user: { roles: [role.id.to_s] } }
            end.to change { user.reload.roles.pluck(:name) }
              .from([old_role.name])
              .to([role.name])
              .and avoid_changing { user.reload.email }

            it_redirects_to_with_notice(root_path, "User was successfully updated.")
          end
        end
      end

      # Keep the array in case we need to add another role like this.
      %w[support].each do |admin_role|
        context "when admin has #{admin_role} role" do
          before { admin.update(roles: [admin_role]) }

          it "prevents admins with #{admin_role} role from updating roles" do
            expect do
              put :update, params: { id: user.login, user: { roles: [role.id.to_s] } }
            end.to raise_exception(ActionController::UnpermittedParameters)
            expect(user.reload.roles).not_to include(role)
          end

          it "allows admins with #{admin_role} role to update email" do
            expect do
              put :update, params: { id: user.login, user: { email: "updated@example.com" } }
            end.to change { user.reload.email }
              .from("user@example.com")
              .to("updated@example.com")
              .and avoid_changing { user.reload.roles.pluck(:name) }

            it_redirects_to_with_notice(root_path, "User was successfully updated.")
          end
        end
      end
    end
  end

  describe "POST #update_next_of_kin" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }
    let(:kin) { create(:user) }

    before { fake_login_admin(admin) }

    shared_examples "unauthorized admin cannot add next of kin" do
      it "redirects with error" do
        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_name: kin.login, next_of_kin_email: kin.email
        }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        expect(user.reload.fannish_next_of_kin).to be_nil
      end
    end

    shared_examples "authorized admin can add next of kin" do
      it "adds next of kin and redirects with notice" do
        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_name: kin.login, next_of_kin_email: kin.email
        }
        it_redirects_to_with_notice(admin_user_path(user), "Fannish next of kin was updated.")
        expect(user.reload.fannish_next_of_kin.kin).to eq(kin)
        expect(user.reload.fannish_next_of_kin.kin_email).to eq(kin.email)
      end
    end

    context "when admin does not have correct authorization" do
      before { admin.update(roles: []) }

      it_behaves_like "unauthorized admin cannot add next of kin"
    end

    %w[superadmin policy_and_abuse support].each do |role|
      context "when admin has #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it_behaves_like "authorized admin can add next of kin"
      end
    end

    context "when admin has support role" do
      let(:admin) { create(:support_admin) }

      before { fake_login_admin(admin) }

      it "logs adding a fannish next of kin" do
        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_name: kin.login, next_of_kin_email: kin.email
        }
        user.reload
        expect(user.fannish_next_of_kin.kin).to eq(kin)
        log_item = user.log_items.last
        expect(log_item.action).to eq(ArchiveConfig.ACTION_ADD_FNOK)
        expect(log_item.fnok_user.id).to eq(kin.id)

        added_log_item = kin.reload.log_items.last
        expect(added_log_item.action).to eq(ArchiveConfig.ACTION_ADDED_AS_FNOK)
        expect(added_log_item.fnok_user.id).to eq(user.id)

        expect_changes_made_by(admin, [log_item, added_log_item])
      end

      it "logs removing a fannish next of kin" do
        kin = create(:fannish_next_of_kin, user: user).kin

        post :update_next_of_kin, params: {
          user_login: user.login
        }
        user.reload
        expect(user.fannish_next_of_kin).to be_nil
        log_item = user.log_items.last
        expect(log_item.action).to eq(ArchiveConfig.ACTION_REMOVE_FNOK)
        expect(log_item.fnok_user.id).to eq(kin.id)

        removed_log_item = kin.reload.log_items.last
        expect(removed_log_item.action).to eq(ArchiveConfig.ACTION_REMOVED_AS_FNOK)
        expect(removed_log_item.fnok_user.id).to eq(user.id)

        expect_changes_made_by(admin, [log_item, removed_log_item])
      end

      it "logs updating a fannish next of kin" do
        previous_kin = create(:fannish_next_of_kin, user: user).kin

        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_name: kin.login, next_of_kin_email: kin.email
        }
        user.reload
        expect(user.fannish_next_of_kin.kin).to eq(kin)

        remove_log_item = user.log_items[-2]
        expect(remove_log_item.action).to eq(ArchiveConfig.ACTION_REMOVE_FNOK)
        expect(remove_log_item.fnok_user.id).to eq(previous_kin.id)

        add_log_item = user.log_items.last
        expect(add_log_item.action).to eq(ArchiveConfig.ACTION_ADD_FNOK)
        expect(add_log_item.fnok_user.id).to eq(kin.id)

        removed_log_item = previous_kin.reload.log_items.last
        expect(removed_log_item.action).to eq(ArchiveConfig.ACTION_REMOVED_AS_FNOK)
        expect(removed_log_item.fnok_user.id).to eq(user.id)

        added_log_item = kin.reload.log_items.last
        expect(added_log_item.action).to eq(ArchiveConfig.ACTION_ADDED_AS_FNOK)
        expect(added_log_item.fnok_user.id).to eq(user.id)

        expect_changes_made_by(admin, [remove_log_item, add_log_item, removed_log_item, added_log_item])
      end

      def expect_changes_made_by(admin, log_items)
        log_items.each do |log_item|
          expect(log_item.admin_id).to eq(admin.id)
          expect(log_item.note).to eq("Change made by #{admin.login}")
        end
      end

      it "does nothing if changing the fnok to themselves" do
        previous_kin = create(:fannish_next_of_kin, user: user)

        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_name: previous_kin.kin.login, next_of_kin_email: previous_kin.kin_email
        }
        it_redirects_to_with_notice(admin_user_path(user), "No change to fannish next of kin.")
        expect(user.reload.log_items).to be_empty
      end

      it "errors if trying to add an incomplete fnok" do
        post :update_next_of_kin, params: {
          user_login: user.login, next_of_kin_email: ""
        }

        kin = assigns(:user).fannish_next_of_kin
        expect(kin).not_to be_valid
        expect(kin.errors[:kin_email]).to include("can't be blank")

        expect(user.reload.log_items).to be_empty
      end
    end
  end

  describe "POST #update_status" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    before { fake_login_admin(admin) }

    shared_examples "unauthorized admin cannot add note to user" do
      it "redirects with error" do
        post :update_status, params: {
          user_login: user.login, admin_action: "note", admin_note: "User likes me, user likes me not."
        }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "authorized admin can add note to user" do
      it "saves note and redirects with notice" do
        admin_note = "User likes me, user likes me not."
        post :update_status, params: {
          user_login: user.login, admin_action: "note", admin_note: admin_note
        }
        it_redirects_to_with_notice(admin_user_path(user), "Note was recorded.")
        expect(user.reload.log_items.last.action).to eq(ArchiveConfig.ACTION_NOTE)
        expect(user.log_items.last.note).to eq(admin_note)
      end
    end

    shared_examples "unauthorized admin cannot suspend user" do
      it "redirects with error" do
        post :update_status, params: {
          user_login: user.login, admin_action: "suspend", suspend_days: "3", admin_note: "User violated community guidelines"
        }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        expect(user.reload.suspended).to be_falsey
      end
    end

    shared_examples "authorized admin can suspend user" do
      it "suspends user and redirects with notice" do
        post :update_status, params: {
          user_login: user.login, admin_action: "suspend", suspend_days: "3", admin_note: "User violated community guidelines"
        }
        it_redirects_to_with_notice(admin_user_path(user), "User has been temporarily suspended.")
        expect(user.reload.suspended).to be_truthy
      end
    end

    context "when admin does not have correct authorization" do
      before { admin.update(roles: []) }

      it_behaves_like "unauthorized admin cannot add note to user"
      it_behaves_like "unauthorized admin cannot suspend user"
    end

    %w[superadmin policy_and_abuse].each do |role|
      context "when admin has #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it_behaves_like "authorized admin can add note to user"
        it_behaves_like "authorized admin can suspend user"
      end
    end

    context "when admin has support role" do
      let(:admin) { create(:support_admin) }

      it_behaves_like "authorized admin can add note to user"
      it_behaves_like "unauthorized admin cannot suspend user"
    end
  end

  describe "GET #confirm_delete_user_creations" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, banned: true) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :confirm_delete_user_creations, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      context "when user is not banned" do
        it "redirects with error" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: false)
          get :confirm_delete_user_creations, params: { id: user.login }

          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end
      end

      context "when user is banned" do
        it "allows admins to access delete user creations page" do
          admin.update(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          user.update(banned: true)
          get :confirm_delete_user_creations, params: { id: user.login }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "POST #destroy_user_creations" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }
    let!(:work) { create(:work, authors: [user.default_pseud]) }
    let(:other_owner) { create(:user, banned: false) }
    let!(:collection1) { create(:collection) }
    let!(:collection2) { create(:collection) }

    before do
      # Banning user only after creating works for them
      user.update!(banned: true)

      collection1.collection_participants = [create(:collection_participant, user: user, collection: collection1, participant_role: CollectionParticipant::OWNER)]
      collection1.save
      create(:collection_participant, user: other_owner, collection: collection2, participant_role: CollectionParticipant::OWNER)
      create(:collection_participant, user: user, collection: collection2, participant_role: CollectionParticipant::MEMBER)
    end

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :destroy_user_creations, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      before do
        admin.update!(roles: ["policy_and_abuse"])
        fake_login_admin(admin)
      end

      context "when user is not banned" do
        it "redirects with error" do
          user.update(banned: false)
          post :destroy_user_creations, params: { id: user.login }

          it_redirects_to_with_error(admin_users_path, "That user is not banned!")
        end
      end

      context "when user is banned" do
        it "allows admins to destroy user creations" do
          post :destroy_user_creations, params: { id: user.login }
          # Check that the first user's collection is deleted
          expect(Collection.exists?(collection1.id)).to be_falsey
          # Check that the second user's collection still exists
          expect(Collection.exists?(other_owner.collections.last.id)).to be_truthy

          it_redirects_to_with_notice(admin_users_path, "All creations by user #{user.login} have been deleted.")
          expect(Work.exists?(work.id)).to be false
        end
      end
    end
  end

  describe "GET #troubleshoot" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :troubleshoot, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows admins to troublehoot user account" do
        admin.update(roles: ["support"])
        fake_login_admin(admin)
        get :troubleshoot, params: { id: user.login }

        it_redirects_to_with_notice(root_path, "User account troubleshooting complete.")
      end
    end
  end

  describe "POST #activate" do
    let(:admin) { create(:admin) }
    let(:user) { create(:user) }

    context "when admin does not have correct authorization" do
      it "redirects with error" do
        admin.update(roles: [])
        fake_login_admin(admin)
        post :activate, params: { id: user.login }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when admin has correct authorization" do
      it "allows admins to troublehoot user account" do
        admin.update(roles: ["support"])
        fake_login_admin(admin)
        post :activate, params: { id: user.login }

        it_redirects_to_with_notice(admin_user_path(id: user.login), "User Account Activated")
      end
    end
  end
end
