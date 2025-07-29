require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  authorized_admin_roles = UserPolicy::MANAGE_ROLES

  describe "GET #index" do
    let(:success_admin) { expect(response).to render_template("index") }

    subject { get :index, params: { user_id: user.login } }

    it_behaves_like "an action only authorized admins can access", authorized_admin_roles
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #manage" do
    let(:success_admin) { expect(response).to render_template("manage") }

    subject { get :manage, params: { user_id: user.login } }

    it_behaves_like "an action only authorized admins can access", authorized_admin_roles
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "GET #show" do
    let(:invitation) { create(:invitation) }
    let(:success_admin) { expect(response).to render_template("show") }

    context "with both user_id and [invitation] id parameters" do

      subject do
        owner = user
        invite = create(:invitation, creator: owner)
        get :show, params: { user_id: owner.login, id: invite.id }
      end

      it "succeeds when logged in as the invitation owner" do
        invitation_owner = create(:user)
        user_invitation = create(:invitation, creator: invitation_owner)
        fake_login_known_user(invitation_owner)
        get :show, params: { user_id: invitation_owner.login, id: user_invitation.id }

        expect(response).to render_template("show")
      end

      it_behaves_like "an action only authorized admins can access", authorized_admin_roles
      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access" # a user who is not the invitation owner
    end


      subject do
        owner = user
        invite = create(:invitation, creator: owner)
        get :show, params: { id: invite.id }
      end
    context "with [invitation] id parameter and no user_id parameter" do

      it "redirects with error when logged in as the invitation owner" do
        invitation_owner = user
        user_invitation = create(:invitation, creator: invitation_owner)
        fake_login_known_user(invitation_owner)
        get :show, params: { id: user_invitation.id }

        it_redirects_to_with_error(user_path(invitation_owner), "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it_behaves_like "an action only authorized admins can access", authorized_admin_roles
      it_behaves_like "an action guests cannot access"
      it_behaves_like "an action users cannot access" # a user who is not the invitation owner
    end
  end

  describe "POST #invite_friend" do
    let(:invitation) { create(:invitation) }
    let(:success) do
      it_redirects_to_with_notice(invitation_path(invite), "Invitation was successfully sent.")
      expect(Invitation.find_by(id: invite.id)).not_to be_nil
    end

    subject do
      owner = user
      invite = create(:invitation, creator: owner)
      post :invite_friend, params: { user_id: owner.id, id: invite.id, invitation: { invitee_email: "not_a_user@example.com" } }
    end

    context "when logged in as the invitation owner" do
      it "succeeds" do
        owner = user
        invite = create(:invitation, creator: owner)
        fake_login_known_user(owner)
        post :invite_friend, params: { user_id: owner.id, id: invite.id, invitation: { invitee_email: "not_a_user@example.com" } }

        it_redirects_to_with_notice(user_path(owner), "Invitation was successfully sent.") # TODO notice isn't showing up
        expect(Invitation.find_by(id: invite.id)).not_to be_nil
      end

      it "errors if email is missing" do
        owner = user
        invite = create(:invitation, creator: owner)
        fake_login_known_user(owner)
        post :invite_friend, params: { user_id: owner.id, id: invite.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without a notice if the invitation fails to save" do
        owner = user
        invite = create(:invitation, creator: owner)
        fake_login_known_user(owner)
        allow_any_instance_of(Invitation).to receive(:save).and_return(false)
        post :invite_friend, params: { user_id: owner.id, id: invite.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end

    context "when logged in as an authorized admin" do
      it "errors if email is missing" do
        fake_login_admin("policy_and_abuse")
        post :invite_friend, params: { user_id: inviter.id, id: invitation.id, invitation: { invitee_email: nil } }

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

    it_behaves_like "an action unauthorized admins cannot access", authorized_admin_roles
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access" # a user who is not the invitation owner
  end

  describe "POST #create" do
    let(:success_admin) do
      it_redirects_to_with_notice(user_invitations_path(user), "Invitations were successfully created.")
      expect(Invitation.find_by(invitee_email: user.email)).not_to be_nil
    end

    subject { post :create, params: { user_id: user.login, invitation: { invitee_email: user.email } } }

    it_behaves_like "an action only authorized admins can access", authorized_admin_roles # fsr success_admin isn't getting to "an action authorized admins can access"
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end

  describe "PUT #update" do
    let(:invitation) { create(:invitation) }
    let(:access_denied_admin) do
      it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      expect(invitation.reload.invitee_email).to eq(old_email)
    end
    let(:access_denied_guest) do
      it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      expect(invitation.reload.invitee_email).to eq(old_email)
    end
    let(:access_denied_user) do
      it_redirects_to_with_notice(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      expect(invitation.reload.invitee_email).to eq(old_email)
    end
    new_email = "not_a_user@example.com"

    subject do
      old_email = invitation.invitee_email
      put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } }
    end

    context "when logged in as an authorized admin" do
      authorized_admin_roles.each do |role|
        context "with role #{role}" do
          before do
            admin.update!(roles: [role])
            fake_login_admin(admin)
          end

          it "errors if email is missing" do
          it "succeeds" do
            subject

            it_redirects_to_with_notice(find_admin_invitations_path("invitation[token]" => invitation.token), "Invitation was successfully sent.")
            expect(invitation.reload.invitee_email).to eq(new_email)
          end

            put :update, params: { id: invitation.id, invitation: { invitee_email: nil } }

            expect(response).to render_template("show")
            expect(flash[:error]).to match("Please enter an email address.")
          end

          it "renders #show without notice if the invitation fails to update" do
            allow_any_instance_of(Invitation).to receive(:update).and_return(false)
            put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } }

            expect(response).to render_template("show")
            expect(flash[:notice]).to be(nil)
          end
        end
      end
    end

    context "when logged in as the invitation owner" do
      before { fake_login_known_user(invitation.creator) }

      it "errors if email is missing" do
        put :update, params: { id: invitation.id, invitation: { invitee_email: nil } }

        expect(response).to render_template("show")
        expect(flash[:error]).to match("Please enter an email address.")
      end

      it "renders #show without notice if the invitation fails to update" do
        allow_any_instance_of(Invitation).to receive(:update).and_return(false)
        put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } }

        expect(response).to render_template("show")
        expect(flash[:notice]).to be(nil)
      end
    end

    it_behaves_like "an action unauthorized admins cannot access", authorized_admin_roles
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access" # a user who is not the invitation owner
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
            let(:invitation) { create(:invitation, creator: user) }

            it "succeeds" do
              subject

              it_redirects_to_with_notice(user_invitations_path(user), "Invitation successfully destroyed")
              expect(Invitation.find_by(id: invitation.id)).to be_nil
            end

            it "redirects with error if invitation fails to destroy" do
              allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
              subject

              it_redirects_to_with_error(user_invitations_path(user), "Invitation was not destroyed.")
            end
          end

          context "when invitation creator is an admin" do
            let(:invitation) { create(:invitation, creator: admin) }

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

          context "when there is no invitation creator" do # invitation created by queue
            let(:invitation) { create(:invitation, creator: nil) }

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

    it_behaves_like "an action unauthorized admins cannot access", authorized_admin_roles
    it_behaves_like "an action guests cannot access"
    it_behaves_like "an action users cannot access"
  end
end
