# frozen_string_literal: true

require "spec_helper"

describe SkinsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:admin) { create(:admin) }

  describe "GET #edit" do
    shared_examples "unauthorized admin cannot edit" do |role:|
      before do
        if role == "no"
          admin.update(roles: [])
        else
          admin.update(roles: [role])
        end
        fake_login_admin(admin)
      end

      it "redirects with error when admin has #{role} role" do
        get :edit, params: { id: skin.id }
        it_redirects_to_with_error(root_path(skin), "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "authorized admin can edit" do |role:|
      before do
        admin.update(roles: [role])
        fake_login_admin(admin)
      end

      it "renders edit template when admin has #{role} role" do
        get :edit, params: { id: skin.id }
        expect(response).to render_template(:edit)
      end
    end

    context "with a site skin" do
      let(:skin) { create(:skin, :public) }

      %w[no board communications docs open_doors policy_and_abuse support tag_wrangling translation].each do |role|
        it_behaves_like "unauthorized admin cannot edit", role: role
      end

      it_behaves_like "authorized admin can edit", role: "superadmin"
    end

    context "with a work skin" do
      let(:skin) { create(:work_skin, :public) }

      %w[no board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it_behaves_like "unauthorized admin cannot edit", role: role
      end

      %w[superadmin support].each do |role|
        it_behaves_like "authorized admin can edit", role: role
      end
    end
  end

  describe "PUT #update" do
    let(:skin_params) do
      {
        skin: {
          title: "Edited title"
        }
      }
    end

    shared_examples "unauthorized admin cannot update" do |role:|
      before do
        if role == "no"
          admin.update(roles: [])
        else
          admin.update(roles: [role])
        end
        fake_login_admin(admin)
      end

      it "does not modify the skin when admin has #{role} role" do
        expect do
          put :update, params: { id: skin.id }.merge(skin_params)
        end.not_to change { skin.reload.title }
      end
    end

    shared_examples "authorized admin can update" do |role:|
      before do
        admin.update(roles: [role])
        fake_login_admin(admin)
      end

      it "modifies the skin when admin has #{role} role" do
        expect do
          put :update, params: { id: skin.id }.merge(skin_params)
        end.to change { skin.reload.title }.to("Edited title")
      end
    end

    context "with a site skin" do
      let(:skin) { create(:skin, :public) }

      %w[no board communications docs open_doors policy_and_abuse support tag_wrangling translation].each do |role|
        it_behaves_like "unauthorized admin cannot update", role: role
      end

      it_behaves_like "authorized admin can update", role: "superadmin"
    end

    context "with a work skin" do
      let(:skin) { create(:work_skin, :public) }

      %w[no board communications docs open_doors policy_and_abuse tag_wrangling translation].each do |role|
        it_behaves_like "unauthorized admin cannot update", role: role
      end

      %w[superadmin support].each do |role|
        it_behaves_like "authorized admin can update", role: role
      end
    end
  end
end
