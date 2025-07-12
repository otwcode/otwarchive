require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  authorized_admin_roles = UserPolicy::MANAGE_ROLES

  shared_examples "an action guests cannot access" do
    subject

    it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
  end

  shared_examples "an action users cannot access" do
    fake_login
    subject

    it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
  end

  describe "GET #index" do
    subject { get :index, params: { user_id: user.login } }
    success { expect(response).to render_template("index") }

    it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #manage" do
    subject { get :manage, params: { user_id: user.login } }
    success { expect(response).to render_template("manage") }

    it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #show" do
    let(:invitation) { create(:invitation, creator: user) }
    success { expect(response).to render_template("show") }

    context "with both user_id and [invitation] id parameters" do
      subject { get :show, params: { user_id: user.login, id: invitation.id } }

      it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
      end
      it_behaves_like "an action users cannot access"
      it_behaves_like "an action guests cannot access"

      context "when logged in as the invitation owner" do
        it "succeeds"
          owned_invitation = invitation
          fake_login_known_user(user)
          get :show, params: { user_id: user.login, id: owned_invitation.id }

          success
        end
      end
    end

    context "with [invitation] id parameter and no user_id parameter" do
      subject { get :show, params: { id: invitation.id } }

      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access"
      it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
      end

      context "when logged in as the invitation owner" do
        it "redirects with error" do
          owned_invitation = invitation
          fake_login_known_user(user)
          get :show, params: { id: owned_invitation.id }

          it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end
    end
  end

  describe "POST #invite_friend" do
    let(:invitation) { create(:invitation, creator: user) }
    before do
      owned_invitation = invitation
      invitation_owner = invitation.creator
    end
    subject { post :invite_friend, params: { user_id: invitation_owner.id, id: owned_invitation.id, invitation: { invitee_email: "not_a_user@example.com" } } }
    success do
      it_redirects_to_with_notice(invitation_path(owned_invitation), "Invitation was successfully sent.")
      expect(Invitation.find_by(id: owned_invitation.id)).not_to be_nil
    end

    it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access" # a random user, as opposed to the invitation owner

    context "when logged in as the invitation owner" do
      it "succeeds" do
        fake_login_known_user(invitation_owner)
        subject

        success
      end

      it "errors if email is missing" do
        fake_login_known_user(invitation_owner)
        post :invite_friend, params: { user_id: invitation_owner.id, id: owned_invitation.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without a notice if the invitation fails to save" do
        allow_any_instance_of(Invitation).to receive(:save).and_return(false)
        fake_login_known_user(invitation_owner)
        subject

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end

    context "when logged in as an authorized admin" do
      it "errors if email is missing" do
        fake_login_admin("policy_and_abuse")
        post :invite_friend, params: { user_id: user.id, id: invitation.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without a notice if the invitation fails to save" do
        allow_any_instance_of(Invitation).to receive(:save).and_return(false)
        fake_login_admin("policy_and_abuse")
        subject

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end
  end

  describe "POST #create" do
    let(:invitee) { create(:user) }
    subject { post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email } } }
    success do
      it_redirects_to_with_notice(user_invitations_path(invitee), "Invitations were successfully created.")
      expect(Invitation.find_by(id: invitation.id)).not_to be_nil
    end

    it_behaves_like "an action only authorized admins can access" do |roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "PUT #update" do
    let(:invitee) { create(:user) }
    let(:invitation) { create(:invitation) }
    new_email = "definitely_not_a_user@example.com"
    subject { put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } } }
    success do
      it_redirects_to_with_notice(find_admin_invitations_path("invitation[token]" => invitation.token), "Invitation was successfully sent.")
      expect(invitation.reload.invitee_email).to eq(new_email)
    end

    it_behaves_like "an action authorized admins can access" do |roles: authorized_admin_roles|
    end

    context "when logged in as an authorized admin" do
      authorized_roles.each do |role|
        context "with role #{role}" do
          before do
            admin.update!(roles: [role])
            fake_login_admin(admin)
          end

          it "errors if email is missing" do
            put :update, params: { id: invitation.id, invitation: { invitee_email: nil } }

            expect(response).to render_template("show")
            expect(flash[:error]).to match("Please enter an email address.")
          end

          it "renders #show without notice if the invitation fails to update" do
            allow_any_instance_of(Invitation).to receive(:update).and_return(false)
            subject

            expect(response).to render_template("show")
            expect(flash[:notice]).to be(nil)
          end
        end
      end
    end

    context "when logged in as an unauthorized admin" do
      context "with no role" do
        it "redirects with error and does not update the invitation" do
          admin.update!(roles: [])
          fake_login_admin(admin)
          old_email = invitation.invitee_email
          subject

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          expect(invitation.reload.invitee_email).to eq(old_email)
        end
      end

      (Admin::VALID_ROLES - authorized_roles).each do |role|
        context "with role #{role}" do
          it "redirects with error and does not update the invitation" do
            admin.update!(roles: [role])
            fake_login_admin(admin)
            old_email = invitee.email
            invitation.invitee_email = old_email
            subject

            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
            expect(invitation.reload.invitee_email).to eq(old_email)
          end
        end
    end

    context "when logged in as a user" do
      before do
        fake_login
      end

      it "succeeds" do
        subject

        it_redirects_to_with_notice(user_path(controller.current_user), "Invitation was successfully sent.")
        expect(invitation.reload.invitee_email).to eq(new_email)
      end

      it "errors if email is missing" do
        put :update, params: { id: invitation.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without notice if the invitation fails to update" do
        allow_any_instance_of(Invitation).to receive(:update).and_return(false)
        subject

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end

    context "when not logged in" do
      it "redirects with error and does not update the invitation" do
        old_email = invitee.email
        invitation.invitee_email = old_email
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(invitation.reload.invitee_email).to eq(old_email)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:invitation) { create(:invitation, creator: user) }
    subject { delete :destroy, params: { id: invitation.id } }

    context "when logged in as an authorized admin" do
      authorized_admin_roles.each do |role|
        context "with role #{role}" do
          before do
            admin.update!(roles: [role])
            fake_login_admin(admin)
          end

          context "when invitation creator is a user" do
            it "deletes invitation and redirects to user invitations path with notice" do
              subject

              it_redirects_to_with_notice(user_invitations_path(user), "Invitation successfully destroyed")
              expect(Invitation.find_by(id: invitation.id)).to be_nil
            end

            it "redirects to user invitations path with error if invitation fails to destroy" do
              allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
              subject

              it_redirects_to_with_error(user_invitations_path(user), "Invitation was not destroyed.")
            end
          end

          context "when invitation creator is an admin" do
            it "deletes invitation and redirects to admin invitations path with notice" do
              invitation_creator = create(:admin)
              invitation.creator = invitation_creator
              subject

              it_redirects_to_with_notice(admin_invitations_path(), "Invitation successfully destroyed")
              expect(Invitation.find_by(id: invitation.id)).to be_nil
            end

            it "redirects to admin invitations path with error if invitation fails to destroy" do
              allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
              subject

              it_redirects_to_with_error(admin_invitations_path(), "Invitation was not destroyed.")
            end
          end
        end
      end
    end

    context "when logged in an unauthorized admin" do
      context "with no role" do
        it "redirects with error and does not delete the invitation" do
          admin.update!(roles: [])
          fake_login_admin(admin)
          subject

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          expect(Invitation.find_by(id: invitation.id)).to be_nil
        end
      end

      (Admin::VALID_ROLES - authorized_roles).each do |role|
        context "with role #{role}" do
          it "redirects with error and does not delete the invitation" do
            admin.update!(roles: [role])
            fake_login_admin(admin)
            subject

            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
            expect(Invitation.find_by(id: invitation.id)).to be_nil
          end
        end
      end
    end

    context "when not logged in" do
      it "redirects with error and does not delete the invitation" do
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(Invitation.find_by(id: invitation.id)).to be_nil
      end
    end

    context "when logged in as a user" do
      it "redirects with error and does not delete the invitation" do
        fake_login
        subject

        it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
        expect(Invitation.find_by(id: invitation.id)).to be_nil
      end
    end
  end
end
