require "spec_helper"

describe InvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  describe "GET #index" do
    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index, params: { user_id: user.login }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'when admin has correct authorization' do
      it "allows admins to access index" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :index, params: { user_id: user.login }
        expect(response).to render_template("index")
      end
    end
  end

  describe "GET #manage" do
    context 'when admin does not have correct authorization' do
      it "denies random admin access" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :manage, params: { user_id: user.login }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context 'when admin has correct authorization' do
      it "allows admins to access index" do
        admin.update(roles: ['policy_and_abuse'])
        fake_login_admin(admin)
        get :manage, params: { user_id: user.login }
        expect(response).to render_template("manage")
      end
    end
  end

  describe "GET #show" do
    let(:invitation) { create(:invitation) }

    it "allows admins to access show page" do
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)
      get :show, params: { id: invitation.id }
      expect(response).to render_template("show")
    end
  end

  describe "GET #invite_friend" do
    let(:invitation) { create(:invitation) }

    it "does not send invite if email is missing" do
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)
      post :invite_friend, params: { user_id: user.id, id: invitation.id, invitation: { invitee_email: nil, number_of_invites: 1 }}
      expect(response).to render_template("show")
      expect(flash[:error]).to match('Please enter an email address.')
    end

    it "sends invite" do
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)
      post :invite_friend, params: { user_id: user.id, id: invitation.id, invitation: { invitee_email: user.email, number_of_invites: 1 }}
      it_redirects_to_with_notice(invitation_path(invitation), "Invitation was successfully sent.")
    end
  end

  describe "POST #create" do
    let(:invitee) { create(:user) }

    it "does not allow non-admins to create" do
      fake_login
      post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email, number_of_invites: 1 }}

      it_redirects_to_with_error(
        user_path(@current_user),
        "Sorry, you don't have permission to access the page you were trying to reach."
      )
    end

    it "creates invitations" do
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)

      post :create, params: { user_id: invitee.login, invitation: { invitee_email: invitee.email, number_of_invites: 1 }}
      it_redirects_to_with_notice(user_invitations_path(invitee), "Invitations were successfully created.")
    end
  end

  describe "PUT #update" do
    it "updates and resends invitations" do
      invitee = create(:user)
      invitation = create(:invitation)
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)

      put :update, params: { id: invitation.id, invitation: { invitee_email: invitee.email }}
      it_redirects_to_with_notice(
        find_admin_invitations_path("invitation[token]" => invitation.token),
        'Invitation was successfully sent.'
      )
    end
  end

  describe "DELETE #destroy" do
    it "does not allow non-admins to destroy" do
      invitation = create(:invitation)
      fake_login
      post :destroy, params: { id: invitation.id }

      it_redirects_to_with_error(
        user_path(@current_user),
        "Sorry, you don't have permission to access the page you were trying to reach."
      )
    end

    it "deletes invitations" do
      invitation = create(:invitation)
      admin.update(roles: ['policy_and_abuse'])
      fake_login_admin(admin)

      post :destroy, params: { id: invitation.id }
      it_redirects_to_with_notice(admin_invitations_path, "Invitation successfully destroyed")
    end
  end
end
