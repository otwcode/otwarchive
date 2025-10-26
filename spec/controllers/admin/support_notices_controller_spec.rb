require "spec_helper"

describe Admin::SupportNoticesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:support_notice) { create(:support_notice) }
  let(:support_notice_params) { attributes_for(:support_notice) }

  shared_examples "only authorized admins are allowed" do |authorized_roles:|
    authorized_roles.each do |role|
      it "succeeds for #{role} admins" do
        fake_login_admin(create(:admin, roles: [role]))
        subject
        success
      end
    end

    (Admin::VALID_ROLES - authorized_roles).each do |role|
      it "displays an error to #{role} admins" do
        fake_login_admin(create(:admin, roles: [role]))
        subject
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    it "displays an error to admins with no role" do
      fake_login_admin(create(:admin, roles: []))
      subject
      it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
    end

    it "redirects logged out users to root with notice" do
      subject
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end

    it "redirects logged in users to root with notice" do
      fake_login
      subject
      it_redirects_to_with_notice(root_path, "I'm sorry, only an admin can look at that area")
    end
  end
  
  shared_examples "only inactive notices can be deleted" do
    let(:support_notice) { create(:support_notice, :active) }

    it "redirects with an error" do
      fake_login_admin(create(:admin, roles: ["superadmin"]))
      subject
      it_redirects_to_with_error(admin_support_notice_path(support_notice), "Active support notices cannot be deleted.")
    end
  end

  describe "GET #index" do
    subject { get :index }

    let(:success) do
      expect(response).to render_template(:index)
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "GET #show" do
    subject { get :show, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:show)
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "GET #new" do
    subject { get :new }

    let(:success) do
      expect(response).to render_template(:new)
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "POST #create" do
    subject { post :create, params: { support_notice: support_notice_params } }

    let(:success) do
      it_redirects_to_with_notice(admin_support_notice_url(assigns[:support_notice]), "Support Notice successfully created.")
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:edit)
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "PUT #update" do
    subject { put :update, params: { id: support_notice, support_notice: support_notice_params } }

    let(:success) do
      expect { support_notice.reload }
        .to change { support_notice.notice }
      it_redirects_to_with_notice(admin_support_notice_url(support_notice), "Support Notice successfully updated.")
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
  end

  describe "GET #confirm_delete" do
    subject { get :confirm_delete, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:confirm_delete)
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
    it_behaves_like "only inactive notices can be deleted"
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: support_notice } }

    let(:success) do
      expect { support_notice.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
      it_redirects_to_with_notice(admin_support_notices_path, "Support Notice successfully deleted.")
    end

    it_behaves_like "only authorized admins are allowed", authorized_roles: %w[superadmin support]
    it_behaves_like "only inactive notices can be deleted"
  end
end
