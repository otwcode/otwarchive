require "spec_helper"

describe Admin::BannersController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin, roles: ["superadmin"]) }
  let(:admin_banner) { create(:admin_banner) }
  let(:admin_banner_params) { attributes_for(:admin_banner) }

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

  describe "GET #index" do
    subject { get :index }

    let(:success) do
      expect(response).to render_template(:index)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications development_and_membership support]
  end

  describe "GET #show" do
    subject { get :show, params: { id: admin_banner } }

    let(:success) do
      expect(response).to render_template(:show)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications development_and_membership support]
  end

  describe "GET #new" do
    subject { get :new }

    let(:success) do
      expect(response).to render_template(:new)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications support]
  end

  describe "POST #create" do
    subject { post :create, params: { admin_banner: admin_banner_params } }

    let(:success) do
      it_redirects_to_with_notice(assigns[:admin_banner], "Banner successfully created.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target).to eq(assigns(:admin_banner))
      expect(AdminActivity.last.action).to eq("create_admin_banner")
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.summary).to include(admin_banner_params[:content])
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications support]
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: admin_banner } }

    let(:success) do
      expect(response).to render_template(:edit)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications development_and_membership support]
  end

  describe "PUT #update" do
    subject { put :update, params: { id: admin_banner, admin_banner: admin_banner_params } }

    let(:success) do
      expect { admin_banner.reload }.to change { admin_banner.content }
      it_redirects_to_with_notice(admin_banner, "Banner successfully updated.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target).to eq(assigns(:admin_banner))
      expect(AdminActivity.last.action).to eq("update_admin_banner")
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.summary).to include(admin_banner_params[:content])
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications development_and_membership support]
  end

  describe "GET #confirm_delete" do
    subject { get :confirm_delete, params: { id: admin_banner } }

    let(:success) do
      expect(response).to render_template(:confirm_delete)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications support]
    
    it "redirects to show page with error for active banners" do
      fake_login_admin(create(:admin, roles: ["superadmin"]))
      active_banner = create(:admin_banner, active: true)
      get :confirm_delete, params: { id: active_banner }
      it_redirects_to_with_error(admin_banner_path(active_banner), "Active banners cannot be deleted.")
    end
  end

  describe "DELETE #destroy" do
    let!(:admin_banner) { create(:admin_banner) }
    subject { delete :destroy, params: { id: admin_banner } }

    let(:success) do
      expect { admin_banner.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      it_redirects_to_with_notice(admin_banners_path, "Banner successfully deleted.")
    end

    it "creates admin activity" do
      fake_login_admin(admin)
      expect { subject }
        .to change { AdminActivity.count }
        .by(1)
      expect(AdminActivity.last.target).to eq(nil)
      expect(AdminActivity.last.action).to eq("destroy_admin_banner")
      expect(AdminActivity.last.admin).to eq(admin)
      expect(AdminActivity.last.summary).to include(admin_banner.content)
    end

    it_behaves_like "only authorized admins are allowed",
                    authorized_roles: %w[superadmin board board_assistants_team communications support]
    
    it "redirects to show page with error for active banners" do
      fake_login_admin(create(:admin, roles: ["superadmin"]))
      active_banner = create(:admin_banner, active: true)
      delete :destroy, params: { id: active_banner }
      it_redirects_to_with_error(admin_banner_path(active_banner), "Active banners cannot be deleted.")
    end
  end
end
