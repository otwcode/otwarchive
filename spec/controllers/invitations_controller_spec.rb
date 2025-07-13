require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  authorized_admin_roles = UserPolicy::MANAGE_ROLES

  describe "GET #index" do
    let(:admin_success) { expect(response).to render_template("index") }

    subject { get :index, params: { user_id: user.login } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #manage" do
    let(:admin_success) { expect(response).to render_template("manage") }

    subject { get :manage, params: { user_id: user.login } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #show" do
    let(:invitation) { create(:invitation) }
    before do
      invite = invitation
      inviter = invite.creator
    end
    let(:admin_success) { expect(response).to render_template("show") }

    context "with both user_id and [invitation] id parameters" do

      subject { get :show, params: { user_id: inviter.login, id: invite.id } }

      it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
      end
      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access" # random users, as opposed to the invitation owner

      context "when logged in as the invitation owner" do
        before { fake_login_known_user(inviter) }

        it "succeeds" do
          subject

          expect(response).to render_template("show")
        end
      end
    end

    context "with [invitation] id parameter and no user_id parameter" do

      subject { get :show, params: { id: invite.id } }

      it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
      end
      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access" # random users, as opposed to the invitation owner

      context "when logged in as the invitation owner" do
        before { fake_login_known_user(inviter) }

        it "redirects with error" do
          subject

          it_redirects_to_with_error(user_path(inviter), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end
    end
  end

  describe "POST #invite_friend" do
    let(:invitation) { create(:invitation) }
    before do
      invite = invitation
      inviter = invite.creator
    end
    let(:admin_success) do
      it_redirects_to_with_notice(invitation_path(invite), "Invitation was successfully sent.")
      expect(Invitation.find_by(id: invite.id)).not_to be_nil
    end

    subject { post :invite_friend, params: { user_id: inviter.id, id: invite.id, invitation: { invitee_email: "not_a_user@example.com" } } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access" # a random user, as opposed to the invitation owner

    context "when logged in as the invitation owner" do
      it "succeeds" do
        fake_login_known_user(inviter)
        subject

        success
      end

      it "errors if email is missing" do
        fake_login_known_user(inviter)
        post :invite_friend, params: { user_id: inviter.id, id: invite.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without a notice if the invitation fails to save" do
        allow_any_instance_of(Invitation).to receive(:save).and_return(false)
        fake_login_known_user(inviter)
        subject

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end

    context "when logged in as an authorized admin" do
      it "errors if email is missing" do
        fake_login_admin("policy_and_abuse")
        post :invite_friend, params: { user_id: inviter.id, id: invite.id, invitation: { invitee_email: nil } }

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
    let(:admin_success) do
      it_redirects_to_with_notice(user_invitations_path(invitee), "Invitations were successfully created.")
      expect(Invitation.find_by(id: invite.id)).not_to be_nil
    end

    subject { post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email } } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "PUT #update" do
    let(:invitation) { create(:invitation) }
    before do
      invite = invitation
      inviter = invite.creator
      old_email = invite.invitee_email
      new_email = "definitely_not_a_user@example.com"
    end
    let(:admin_success) do
      it_redirects_to_with_notice(find_admin_invitations_path("invitation[token]" => invite.token), "Invitation was successfully sent.")
      expect(invite.reload.invitee_email).to eq(new_email)
    end
    let(:access_denied_admin) do
      it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      expect(invite.reload.invitee_email).to eq(old_email)
    end
    let(:access_denied_guest) do
      it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      expect(invite.reload.invitee_email).to eq(old_email)
    end
    let(:access_denied_user) do
      it_redirects_to_with_notice(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      expect(invite.reload.invitee_email).to eq(new_email)
    end

    subject { put :update, params: { id: invite.id, invitation: { invitee_email: new_email } } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access" # random users, as opposed to invitation owner

    context "when logged in as an authorized admin" do
      authorized_admin_roles.each do |role|
        context "with role #{role}" do
          before do
            admin.update!(roles: [role])
            fake_login_admin(admin)
          end

          it "errors if email is missing" do
            put :update, params: { id: invite.id, invitation: { invitee_email: nil } }

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

    context "when logged in as the invitation owner" do
      before { fake_login_known_user(inviter) }

      it "errors if email is missing" do
        put :update, params: { id: invite.id, invitation: { invitee_email: nil } }

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

  describe "DELETE #destroy" do
    let(:invitation) { create(:invitation) }
    let(:access_denied_admin) do
      it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      expect(Invitation.find_by(id: invitation.id)).not_to be_nil
    end
    let(:access_denied_guest) do
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(Invitation.find_by(id: invitation.id)).not_to be_nil
    end
    let(:access_denied_user) do
      it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      expect(Invitation.find_by(id: invitation.id)).not_to be_nil
    end

    subject { delete :destroy, params: { id: invitation.id } }

    context "when logged in as an authorized admin" do
      authorized_admin_roles.each do |role|
        context "with role #{role}" do
          before do
            admin.update!(roles: [role])
            fake_login_admin(admin)
          end

          context "when invitation creator is a user" do
            before do
              inviter = user
              invitation = create(:invitation, creator: inviter)
            end

            it "succeeds" do
              subject

              it_redirects_to_with_notice(user_invitations_path(inviter), "Invitation successfully destroyed")
              expect(Invitation.find_by(id: invitation.id)).to be_nil
            end

            it "redirects with error if invitation fails to destroy" do
              allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
              subject

              it_redirects_to_with_error(user_invitations_path(inviter), "Invitation was not destroyed.")
            end
          end

          context "when invitation creator is an admin" do
            before do
              inviter = admin
              invitation = create(:invitation, creator: inviter)
            end

            it "succeeds" do
              subject

              it_redirects_to_with_notice(admin_invitations_path(), "Invitation successfully destroyed")
              expect(Invitation.find_by(id: invitation.id)).to be_nil
            end

            it "redirects with error if invitation fails to destroy" do
              allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
              subject

              it_redirects_to_with_error(admin_invitations_path(), "Invitation was not destroyed.")
            end
          end
        end
      end
    end

    it_behaves_like "an action unauthorized admins cannot access" do |roles_that_are_authorized: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end
end
