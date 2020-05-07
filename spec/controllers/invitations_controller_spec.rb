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
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
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
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
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
      fake_login_admin(admin)
      get :show, params: { id: invitation.id }
      expect(response).to render_template("show")
    end
  end

  describe "GET #invite_friend" do
    let(:invitation) { create(:invitation) }

    # it "does not send invite if email is missing" do
    #   fake_login_admin(admin)
    #   # invite_friend_user_invitations
    #   post :invite_friend, params: { id: invitation.id, invitation: { invitee_email: nil, number_of_invites: 1 }}
    #   it_redirects_to_with_error(invitation_path(invitation.id), "Please enter an email address.")
    # end

    # it "sends invite" do
    #   fake_login_admin(admin)
    #   # invite_friend_user_invitations
    #   post :invite_friend, params: { id: invitation.id, invitation: { invitee_email: user.email, number_of_invites: 1 }}
    #   expect(response).to render_template("show")
    #   it_redirects_to_with_notice(user_invitation_path(user, invitation), "Invitation was successfully sent.")
    # end
  end

  # describe "GET #create" do

  # describe "GET #update" do

  # describe "GET #destroy" do
end
