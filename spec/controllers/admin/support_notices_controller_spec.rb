require "spec_helper"

describe Admin::SupportNoticesController do
  include LoginMacros
  include RedirectExpectationHelper

  support_notice_roles = %w[superadmin support].freeze

  let(:admin) { create(:admin, roles: ["superadmin"]) }
  let(:support_notice) { create(:support_notice) }
  let(:support_notice_params) { attributes_for(:support_notice, notice: "New notice content") }

  shared_examples "an action users can't access" do
    it "redirects logged out users to root with notice" do
      fake_logout
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
      fake_login_admin(admin)
      subject
      it_redirects_to_with_error(admin_support_notice_path(support_notice), "Active support notices cannot be deleted.")
    end
  end

  describe "GET #index" do
    subject { get :index }

    let(:success) do
      expect(response).to render_template(:index)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "GET #show" do
    subject { get :show, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:show)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "GET #new" do
    subject { get :new }

    let(:success) do
      expect(response).to render_template(:new)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "POST #create" do
    subject { post :create, params: { support_notice: support_notice_params } }

    let(:success) do
      it_redirects_to_with_notice(admin_support_notice_url(assigns[:support_notice]), "Support Notice successfully created.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target).to eq(SupportNotice.last)
      expect(AdminActivity.last.action).to eq("create support notice")
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.summary).to include(support_notice_params[:notice])
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:edit)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "PUT #update" do
    subject { put :update, params: { id: support_notice, support_notice: support_notice_params } }

    let(:success) do
      expect { support_notice.reload }
        .to change { support_notice.notice }
      it_redirects_to_with_notice(admin_support_notice_url(support_notice), "Support Notice successfully updated.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target).to eq(support_notice)
      expect(AdminActivity.last.action).to eq("update support notice")
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.summary).to include(support_notice_params[:notice])
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
  end

  describe "GET #confirm_delete" do
    subject { get :confirm_delete, params: { id: support_notice } }

    let(:success) do
      expect(response).to render_template(:confirm_delete)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
    it_behaves_like "only inactive notices can be deleted"
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: support_notice } }

    let(:success) do
      expect { support_notice.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
      it_redirects_to_with_notice(admin_support_notices_path, "Support Notice successfully deleted.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target_id).to eq(support_notice.id)
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.action).to eq("destroy support notice")
      expect(AdminActivity.last.summary).to include(support_notice.notice)
    end

    it_behaves_like "an action only authorized admins can access", authorized_roles: support_notice_roles
    it_behaves_like "an action users can't access"
    it_behaves_like "only inactive notices can be deleted"
  end
end
