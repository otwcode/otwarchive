# frozen_string_literal: true

require 'spec_helper'

describe CreatorshipsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let(:pending_work) { create(:work) }
  let(:rejected_work) { create(:work) }
  let(:other_user) { create(:user) }

  let(:pending) do
    Creatorship.new(pseud: user.default_pseud, creation: pending_work,
                    approval_status: Creatorship::PENDING)
  end

  let(:rejected) do
    Creatorship.new(pseud: user.default_pseud, creation: rejected_work,
                    approval_status: Creatorship::REJECTED)
  end

  before do
    # Make sure that both invitations are saved without altering the approval
    # status:
    pending.save(validate: false)
    expect(pending.reload.approval_status).to eq(Creatorship::PENDING)
    rejected.save(validate: false)
    expect(rejected.reload.approval_status).to eq(Creatorship::REJECTED)
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
        expect(assigns[:creatorships]).to contain_exactly(pending)
        expect(response).to render_template :show
      end

      it "displays rejected invitations" do
        fake_login_admin(create(:admin))
        get :show, params: params.merge(show: "rejected")
        expect(assigns[:creatorships]).to contain_exactly(rejected)
        expect(response).to render_template :show
      end
    end

    context "when logged in as the user" do
      it "displays invitations" do
        fake_login_known_user(user)
        get :show, params: params
        expect(assigns[:creatorships]).to contain_exactly(pending)
        expect(response).to render_template :show
      end

      it "displays rejected invitations" do
        fake_login_known_user(user)
        get :show, params: params.merge(show: "rejected")
        expect(assigns[:creatorships]).to contain_exactly(rejected)
        expect(response).to render_template :show
      end
    end
  end

  describe "#update" do
    let(:params) do
      { user_id: user.login, selected: [pending.id] }
    end

    context "when logged out" do
      it "redirects with an error message" do
        put :update, params: params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as another user" do
      it "redirects with an error message" do
        fake_login_known_user(other_user)
        put :update, params: params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as an admin" do
      it "redirects with an error message" do
        fake_login_admin(create(:admin))
        put :update, params: params
        it_redirects_to_with_error(user, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as the user" do
      it "accepts invitations after pressing 'Accept'" do
        fake_login_known_user(user)
        put :update, params: params.merge(accept: "Accept")
        expect(assigns[:creatorships]).to contain_exactly(pending)
        expect(pending.reload.approval_status).to eq(Creatorship::APPROVED)
        expect(pending_work.pseuds.reload).to include(user.default_pseud)
      end

      it "rejects invitations after pressing 'Reject'" do
        fake_login_known_user(user)
        put :update, params: params.merge(reject: "Reject")
        expect(assigns[:creatorships]).to contain_exactly(pending)
        expect(pending.reload.approval_status).to eq(Creatorship::REJECTED)
        expect(pending_work.pseuds.reload).not_to include(user.default_pseud)
      end

      it "deletes invitations after pressing 'Delete'" do
        fake_login_known_user(user)
        put :update, params: params.merge(delete: "Delete")
        expect(assigns[:creatorships]).to contain_exactly(pending)
        expect { pending.reload }.to raise_error(ActiveRecord::RecordNotFound)
        expect(pending_work.pseuds.reload).not_to include(user.default_pseud)
      end
    end
  end
end
