# frozen_string_literal: true

require "spec_helper"

describe Admin::AdminInvitationsController do
  include LoginMacros
  include RedirectExpectationHelper

  index_roles = %w[superadmin open_doors policy_and_abuse support tag_wrangling].freeze

  describe "GET #index" do
    subject { get :index }
    let(:success) do
      expect(response).to have_http_status(:success)
      expect(response).to render_template("index")
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: index_roles

    it "denies non-admins access to index" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end

  create_roles = %w[superadmin policy_and_abuse support tag_wrangling].freeze

  describe "POST #create" do
    subject { post :create, params: { invitation: { invitee_email: "test_email@example.com" } } }
    let(:success) do
      it_redirects_to_with_notice(admin_invitations_path, "An invitation was sent to test_email@example.com")
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: create_roles

    it "does not allow non-admins to create invites" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end

  invite_from_queue_roles = %w[superadmin policy_and_abuse].freeze

  describe "POST #invite_from_queue" do
    subject { post :invite_from_queue, params: { invitation: { invite_from_queue: "1" } } }
    let(:success) do
      it_redirects_to_with_notice(admin_invitations_path, "1 person from the invite queue is being invited.")
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: invite_from_queue_roles

    it "does not allow non-admins to invite from queue" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end

  grant_to_all_roles = %w[superadmin].freeze

  describe "POST #grant_invites_to_users" do
    subject { post :grant_invites_to_users, params: { invitation: { user_group: "ALL", number_of_invites: "2" } } }
    let(:success) do
      it_redirects_to_with_notice(admin_invitations_path, "Invitations successfully created.")
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: grant_to_all_roles

    it "does not allow non-admins to grant invites to all users" do
      fake_login
      subject

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end

  find_roles = %w[superadmin open_doors policy_and_abuse support].freeze

  describe "GET #find" do
    subject { get :find, params: { invitation: { token: invitation.token } } }
    let(:admin) { create(:superadmin) }
    let(:user) { create(:user) }
    let(:invitation) { create(:invitation) }
    let(:success) do
      expect(response).to render_template("find")
      expect(assigns(:invitations)).to include(invitation)
    end

    it "does not allow non-admins to search" do
      fake_login
      get :find, params: { invitation: { user_name: user.login } }

      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    it "allows admins to search by user_name" do
      user.update!(invitations: [invitation])
      fake_login_admin(admin)
      get :find, params: { invitation: { user_name: user.login } }

      expect(response).to render_template("find")
      expect(assigns(:invitations)).to include(invitation)
    end

    # by token
    it_behaves_like "an action only authorized admins can access", authorized_roles: find_roles

    it "allows admins to search by invitee_email" do
      invitation.update!(invitee_email: user.email)
      fake_login_admin(admin)
      get :find, params: { invitation: { invitee_email: user.email } }

      expect(response).to render_template("find")
      expect(assigns(:invitations)).to include(invitation)
    end
  end
end
