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

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #manage" do
    subject { get :manage, params: { user_id: user.login } }
    success { expect(response).to render_template("manage") }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #show" do
    success { expect(response).to render_template("show") }
    let(:invitation) { create(:invitation) }
    before do
      invite = invitation
      inviter = invite.creator
    end

    context "with both user_id and [invitation] id parameters" do

      subject { get :show, params: { user_id: inviter.login, id: invite.id } }

      it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
      end
      it_behaves_like "an action users cannot access"
      it_behaves_like "an action guests cannot access"

      context "when logged in as the invitation owner" do
        before { fake_login_known_user(inviter) }

        it "succeeds" do
          subject

          expect(response).to render_template("show")
        end
      end
    end

    context "with [invitation] id parameter and no user_id parameter" do

      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access"
      subject { get :show, params: { id: invite.id } }

      it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
      end

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
    let(:invitation) { create(:invitation, creator: user) }
    let(:invitation) { create(:invitation) }
    before do
      invite = invitation
      inviter = invite.creator
    end
    success do
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
    success do
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
    subject { put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } } }
    success do
      it_redirects_to_with_notice(find_admin_invitations_path("invitation[token]" => invitation.token), "Invitation was successfully sent.")
      expect(invitation.reload.invitee_email).to eq(new_email)
    before do
      invite = invitation
      inviter = invite.creator
      old_email = invite.invitee_email
      new_email = "definitely_not_a_user@example.com"
    end
    end

    subject { put :update, params: { id: invite.id, invitation: { invitee_email: new_email } } }

    it_behaves_like "an action only authorized admins can access" do |authorized_roles: authorized_admin_roles|
    end

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

    context "when not logged in" do

  describe "DELETE #destroy" do
    let(:invitation) { create(:invitation) }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(Invitation.find_by(id: invitation.id)).not_to be_nil
    end
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
