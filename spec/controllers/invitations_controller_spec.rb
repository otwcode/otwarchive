require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  authorized_roles = UserPolicy::MANAGE_ROLES

  shared_examples "an action guests cannot access" do
    subject

    it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
  end

  shared_examples "an action users cannot access" do
    fake_login
    subject

    it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
  end

  shared_examples "an action only the invitation owner can access" do |owner:|
    it "succeeds when logged in as the invitation owner" do
      fake_login_known_user(owner)
      subject

      success
    end

    # "users can't access this" errors and "specific user can't access this" errors behave the same.
    it_behaves_like "an action users cannot access"
  end

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        it "redirects with error" do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
          subject

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }
    let(:invitation) { create(:invitation, creator: user) }

    context "with user and id parameters" do
      context "when logged out" do
        it "redirects with error" do
          get :show, params: { user_id: user.login, id: invitation.id }

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when logged in as user who owns invitation" do
        it "renders show template" do
          fake_login_known_user(user)
          get :show, params: { user_id: user.login, id: invitation.id }

          expect(response).to render_template("show")
        end
      end

      context "when logged in as user who does not own invitation" do
        it "redirects with error" do
          fake_login
          get :show, params: { user_id: user.login, id: invitation.id }

          it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end

      context "when logged in as admin without correct authorization" do
        it "redirects with error" do
          fake_login_admin(admin)
          get :show, params: { user_id: user.login, id: invitation.id }

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when logged in as admin with correct authorization" do
        it "renders show template" do
          admin.update!(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          get :show, params: { user_id: user.login, id: invitation.id }

          expect(response).to render_template("show")
        end
      end
    end

    context "with id parameters" do
      context "when logged out" do
        it "redirects with error" do
          get :show, params: { id: invitation.id }

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when logged in as user who owns invitation" do
        it "redirects with error" do
          fake_login_known_user(user)
          get :show, params: { id: invitation.id }

          it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end

      context "when logged in as user who does not own invitation" do
        it "redirects with error" do
          fake_login
          get :show, params: { id: invitation.id }

          it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
        end
      end

      context "when admin does not have correct authorization" do
        it "redirects with error" do
          fake_login_admin(admin)
          get :show, params: { id: invitation.id }

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end

      context "when admin has correct authorization" do
        it "renders show template" do
          admin.update!(roles: ["policy_and_abuse"])
          fake_login_admin(admin)
          get :show, params: { id: invitation.id }

          expect(response).to render_template("show")
        end
      end
    end
  end

  describe "POST #invite_friend" do
    let(:invitation) { create(:invitation) }
    subject { post :invite_friend, params: { user_id: user.id, id: invitation.id, invitation: { invitee_email: user.email, number_of_invites: 1 } } }

    authorized_roles = UserPolicy::MANAGE_ROLES

    authorized_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        before do
          admin.update!(roles:[admin_role])
          fake_login_admin(admin)
        end

        it "sends invitation and redirects to invitation path" do
          subject

          it_redirects_to_with_notice(invitation_path(invitation), "Invitation was successfully sent.")
        end

        it "errors if email is missing" do
          post :invite_friend, params: { user_id: user.id, id: invitation.id, invitation: { invitee_email: nil, number_of_invites: 1 } }

          expect(response).to render_template("show")
          expect(flash[:error]).to match("Please enter an email address.")
        end

        it "renders #show if the invitation fails to save" do
          allow_any_instance_of(Invitation).to receive(:save).and_return(false)
          subject

          expect(response).to render_template("show")
        end
      end
    end

    context "when logged in as an admin with no role" do
      it "redirects with error" do
        admin.update!(roles: [])
        fake_login_admin(admin)
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        it "redirects with error" do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
          subject

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        end
      end
    end
  end

  describe "POST #create" do
    let(:invitee) { create(:user) }

    it "does not allow non-admins to create" do
      fake_login
      post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email, number_of_invites: 1 } }

      it_redirects_to_with_error(
        user_path(controller.current_user),
        "Sorry, you don't have permission to access the page you were trying to reach."
      )
    end

    it "allows admins to create invitations" do
      admin.update!(roles: ["policy_and_abuse"])
      fake_login_admin(admin)
      post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email, number_of_invites: 1 } }

      it_redirects_to_with_notice(user_invitations_path(invitee), "Invitations were successfully created.")
    end
  end

  describe "PUT #update" do
    let(:invitee) { create(:user) }
    let(:invitation) { create(:invitation) }
    subject { put :update, params: { id: invitation.id, invitation: { invitee_email: invitee.email } } }

    authorized_roles = UserPolicy::MANAGE_ROLES

    authorized_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        before do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
        end

        it "updates invitation and redirects to find admin invitations path" do
          new_email = invitee.email
          put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } }

          it_redirects_to_with_notice(find_admin_invitations_path("invitation[token]" => invitation.token), "Invitation was successfully sent.")
          expect(invitation.invitee_email).to eq(new_email)
        end

        it "errors if email is missing" do
          allow_any_instance_of(Invitation).to receive(:update).and_return(false)
          put :update, params: { id: invitation.id, invitation: { invitee_email: nil } }

          expect(response).to render_template("show")
          expect(flash[:error]).to match("Please enter an email address.")
        end

        it "renders #show if the invitation fails to update" do
          allow_any_instance_of(Invitation).to receive(:update).and_return(false)
          subject

          expect(response).to render_template("show")
          expect(flash[:notice]).to be(nil)
        end

        it "renders #show if the update did not change invitee_email" do
          put :update, params: { id: invitation.id, invitation: { invitee_email: invitation.invitee_email } }

          expect(response).to render_template("show")
          expect(flash[:notice]).to be(nil)
        end
      end
    end

    context "when logged in as a user" do
      it "updates invitation and redirects to user path" do
        fake_login
        new_email = invitee.email
        put :update, params: { id: invitation.id, invitation: { invitee_email: new_email } }

        it_redirects_to_simple(user_path(controller.current_user))
        expect(invitation.invitee_email).to eq(new_email)
      end
    end

    context "when logged in as an admin with no role" do
      it "redirects with error and does not update the invitation" do
        admin.update!(roles: [])
        fake_login_admin(admin)
        old_email = invitee.email
        invitation.invitee_email = old_email
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(invitation.invitee_email).to eq(old_email)
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        it "redirects with error and does not update the invitation" do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
          old_email = invitee.email
          invitation.invitee_email = old_email
          subject

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          expect(invitation.invitee_email).to eq(old_email)
        end
      end
    end

    context "when not logged in" do
      it "redirects with error and does not update the invitation" do
        old_email = invitee.email
        invitation.invitee_email = old_email
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(invitation.invitee_email).to eq(old_email)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:invitation) { create(:invitation) }
    subject { delete :destroy, params: { id: invitation.id } }

    authorized_roles = UserPolicy::MANAGE_ROLES

    authorized_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        before do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
        end

        context "when invitation creator is a user" do
          it "deletes invitation and redirects to user invitations path" do
            invitation_creator = create(:user)
            invitation.creator = invitation_creator
            subject

            it_redirects_to_with_notice(user_invitations_path(invitation_creator), "Invitation successfully destroyed")
          end
        end

        context "when invitation creator is an admin" do
          it "deletes invitation and redirects to admin invitations path" do
            invitation_creator = create(:admin)
            invitation.creator = invitation_creator
            subject

            it_redirects_to_with_notice(admin_invitations_path(), "Invitation successfully destroyed")
          end
        end

        it "errors if invitation fails to destroy" do
          allow_any_instance_of(Invitation).to receive(:destroy).and_return(false)
          subject

          expect(flash[:error]).to match("Invitation was not destroyed.")
        end
      end
    end

    context "when logged in as an admin with no role" do
      before do
        admin.update!(roles: [])
        fake_login_admin(admin)
      end

      it "redirects with error and does not delete the invitation" do
        admin.update!(roles: [])
        fake_login_admin(admin)
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(invitation).to exist
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        it "redirects with error and does not delete the invitation" do
          admin.update!(roles: [admin_role])
          fake_login_admin(admin)
          subject

          it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          expect(invitation).to exist
        end
      end
    end

    context "when not logged in" do
      it "redirects with error and does not delete the invitation" do
        subject

        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
        expect(invitation).to exist
      end
    end

    context "when logged in as a user" do
      it "redirects with error and does not delete the invitation" do
        fake_login
        subject

        it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
        expect(invitation).to exist
      end
    end
  end
end
