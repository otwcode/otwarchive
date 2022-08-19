# frozen_string_literal: true

require "spec_helper"

describe Admin::SkinsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }

  describe "GET #index" do
    context "when admin does not have correct authorization" do
      context "when admin has no role" do
        it "redirects with error when admin has no role" do
          admin.update(roles: [])
          fake_login_admin(admin)
          get :index

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      %w[board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[superadmin support].each do |role|
      context "when admin is authorized with the #{role} role" do
        it "renders index template" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index

          expect(response).to render_template(:index)
        end
      end
    end
  end

  describe "GET #index_approved" do
    context "when admin does not have correct authorization" do
      it "redirects with error when admin has no role" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index_approved

        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end

      %w[board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_approved

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[superadmin support].each do |role|
      context "when admin is authorized with the #{role} role" do
        it "renders index_approved template" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_approved

          expect(response).to render_template(:index_approved)
        end
      end
    end
  end

  describe "GET #index_rejected" do
    context "when admin does not have correct authorization" do
      it "redirects with error when admin has no role" do
        admin.update(roles: [])
        fake_login_admin(admin)
        get :index_rejected

        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end

      %w[board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it "redirects with error when admin has #{role} role" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_rejected

          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[superadmin support].each do |role|
      context "when admin is authorized with the #{role} role" do
        it "renders index_rejected template" do
          admin.update(roles: [role])
          fake_login_admin(admin)
          get :index_rejected

          expect(response).to render_template(:index_rejected)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:site_skin) { create(:skin, :public) }
    let(:work_skin) { create(:work_skin, :public) }

    shared_examples "unauthorized admin cannot update site skin" do |role:|
      before do
        if role == "no"
          admin.update(roles: [])
        else
          admin.update(roles: [role])
        end
        fake_login_admin(admin)
      end

      context "when admin has #{role} role" do
        it "does not modify site skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [site_skin.id] }
          end.not_to change { site_skin.reload.official }
        end

        it "redirects with error" do
          put :update, params: { id: :update, make_unofficial: [site_skin.id] }
          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    shared_examples "authorized admin can update site skin" do |role:|
      before do
        admin.update(roles: [role])
        fake_login_admin(admin)
      end

      context "when admin has #{role} role" do
        it "modifies site skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [site_skin.id] }
          end.to change { site_skin.reload.official }
        end

        it "redirects with notice" do
          put :update, params: { id: :update, make_unofficial: [site_skin.id] }
          it_redirects_to_simple(admin_skins_path)
          expect(flash[:notice]).to include("The following skins were updated: #{site_skin.title}")
        end
      end
    end

    shared_examples "unauthorized admin cannot update work skin" do |role:|
      before do
        if role == "no"
          admin.update(roles: [])
        else
          admin.update(roles: [role])
        end
        fake_login_admin(admin)
      end

      context "when admin has #{role} role" do
        it "does not modify work skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id] }
          end.not_to change { work_skin.reload.official }
        end

        it "redirects with error" do
          put :update, params: { id: :update, make_unofficial: [work_skin.id] }
          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    shared_examples "authorized admin can update work skin" do |role:|
      before do
        admin.update(roles: [role])
        fake_login_admin(admin)
      end

      context "when admin has #{role} role" do
        it "modifies work skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id] }
          end.to change { work_skin.reload.official }
        end

        it "redirects with notice" do
          put :update, params: { id: :update, make_unofficial: [work_skin.id] }
          it_redirects_to_simple(admin_skins_path)
          expect(flash[:notice]).to include("The following skins were updated: #{work_skin.title}")
        end
      end
    end

    %w[no board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
      it_behaves_like "unauthorized admin cannot update site skin", role: role
      it_behaves_like "unauthorized admin cannot update work skin", role: role
    end

    context "when admin has superadmin role" do
      it_behaves_like "authorized admin can update site skin", role: "superadmin"
      it_behaves_like "authorized admin can update work skin", role: "superadmin"

      context "when updating site and work skin simultaneously" do
        before do
          admin.update(roles: ["superadmin"])
          fake_login_admin(admin)
        end

        it "modifies work skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          end.to change { work_skin.reload.official }
        end

        it "modifies site skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          end.to change { site_skin.reload.official }
        end

        it "redirects with notice" do
          put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          it_redirects_to_with_notice(admin_skins_path, ["The following skins were updated: #{work_skin.title}, #{site_skin.title}"])
        end
      end
    end

    context "when admin has support role" do
      it_behaves_like "unauthorized admin cannot update site skin", role: "support"
      it_behaves_like "authorized admin can update work skin", role: "support"

      context "when updating site and work skin simultaneously" do
        before do
          admin.update(roles: ["support"])
          fake_login_admin(admin)
        end

        it "modifies work skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          end.to change { work_skin.reload.official }
        end

        it "does not modify site skin" do
          expect do
            put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          end.not_to change { site_skin.reload.official }
        end

        it "redirects with notice" do
          put :update, params: { id: :update, make_unofficial: [work_skin.id, site_skin.id] }
          it_redirects_to_with_notice(admin_skins_path, "The following skins were updated: #{work_skin.title}")
        end
      end
    end
  end
end
