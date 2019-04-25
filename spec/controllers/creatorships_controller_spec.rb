# frozen_string_literal: true

require 'spec_helper'

describe CreatorshipsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let(:work) { create(:work) }
  let(:other_user) { create(:user) }

  let(:invitation) do
    Creatorship.new(pseud: user.default_pseud, creation: work)
  end

  before do
    # Make sure that the invitation is saved with approval set to false.
    invitation.save(validate: false)
    expect(invitation.reload.approved).to be_falsy
  end

  describe "#show" do
    let(:params) do
      { user_id: user.login }
    end

    context "when logged out" do
      it "redirects with an error message" do
        get :show, params: params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as another user" do
      it "redirects with an error message" do
        fake_login_known_user(other_user)
        get :show, params: params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as an admin" do
      it "displays invitations" do
        fake_login_admin(create(:admin))
        get :show, params: params
        expect(assigns[:creatorships]).to contain_exactly(invitation)
        expect(response).to render_template :show
      end
    end

    context "when logged in as the user" do
      it "displays invitations" do
        fake_login_known_user(user)
        get :show, params: params
        expect(assigns[:creatorships]).to contain_exactly(invitation)
        expect(response).to render_template :show
      end
    end
  end

  describe "#update" do
    let(:accept_params) do
      { user_id: user.login, selected: [invitation.id], accept: "Accept" }
    end

    let(:delete_params) do
      { user_id: user.login, selected: [invitation.id], delete: "Delete" }
    end

    context "when logged out" do
      it "redirects with an error message" do
        put :update, params: accept_params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as another user" do
      it "redirects with an error message" do
        fake_login_known_user(other_user)
        put :update, params: accept_params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as an admin" do
      it "redirects with an error message" do
        fake_login_admin(create(:admin))
        put :update, params: accept_params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as the user" do
      it "accepts invitations after pressing 'Accept'" do
        fake_login_known_user(user)
        put :update, params: accept_params
        expect(assigns[:creatorships]).to contain_exactly(invitation)
        expect(invitation.reload.approved).to be_truthy
        expect(work.pseuds.reload).to include(user.default_pseud)
      end

      it "deletes invitations after pressing 'Delete'" do
        fake_login_known_user(user)
        put :update, params: delete_params
        expect(assigns[:creatorships]).to contain_exactly(invitation)
        expect { invitation.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#accept" do
    context "when logged out" do
      it "redirects with an error message" do
        put :accept, params: { work_id: work.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as an admin" do
      it "redirects with an error message" do
        fake_login_admin(create(:admin))
        put :accept, params: { work_id: work.id }
        it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    [:work, :series, :chapter].each do |type|
      context "with an item of type #{type}" do
        let(:item) { create(type) }

        # Override the default definition of invitation so that we have a
        # different type of creation.
        let(:invitation) { Creatorship.new(pseud: user.default_pseud, creation: item) }

        let(:params) do
          { "#{type}_id": item.id }
        end

        context "when logged in as a user with an invitation" do
          it "accepts the invitation and redirects to the item" do
            fake_login_known_user(user)
            put :accept, params: params
            expect(invitation.reload.approved).to be_truthy
            expect(item.pseuds.reload).to include(user.default_pseud)
            it_redirects_to_with_notice(item, "You have accepted the invitation to become a co-creator.")
          end
        end

        context "when logged in as a user without an invitation" do
          it "redirects with an error and doesn't accept the invitation" do
            fake_login_known_user(other_user)
            put :accept, params: params
            expect(invitation.reload.approved).to be_falsy
            expect(item.pseuds.reload).not_to include(user.default_pseud)
            it_redirects_to_with_error(item, "You don't have any creator invitations for this #{type}.")
          end
        end
      end
    end
  end
end
