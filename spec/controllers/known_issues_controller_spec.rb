# frozen_string_literal: true

require "spec_helper"

describe KnownIssuesController do
  include LoginMacros
  include RedirectExpectationHelper

  allowed_roles = %w[superadmin support]

  shared_examples "denies access to unauthorized admins" do
    context "when logged in as an admin with no role" do
      let(:admin) { create(:admin) }

      it "redirects with an error" do
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - allowed_roles).each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        it "redirects with an error" do
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end
  end

  describe "GET #show" do
    let(:known_issue) { create(:known_issue) }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :show, params: { id: known_issue.id }
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "allows access" do
          get :show, params: { id: known_issue.id }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET #new" do
    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :new
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "allows access" do
          get :new
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "GET #edit" do
    let(:known_issue) { create(:known_issue) }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        get :edit, params: { id: known_issue.id }
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "allows access" do
          get :edit, params: { id: known_issue.id }
          expect(response).to have_http_status(:success)
        end
      end
    end
  end

  describe "POST #create" do
    let(:params) { { known_issue: attributes_for(:known_issue) } }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        post :create, params: params
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "creates a known issue" do
          expect { post :create, params: params }
            .to change { KnownIssue.count }
            .by(1)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:known_issue) { create(:known_issue) }
    let(:params) { { id: known_issue.id, known_issue: { title: "Brand new title" } } }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        put :update, params: params
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "updates the known issue successfully" do
          put :update, params: params
          expect(known_issue.reload.title).to eq("Brand new title")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:known_issue) { create(:known_issue) }

    it_behaves_like "denies access to unauthorized admins" do
      before do
        fake_login_admin(admin)
        delete :destroy, params: { id: known_issue.id }
      end
    end

    allowed_roles.each do |admin_role|
      context "when logged in as an admin with role #{admin_role}" do
        let(:admin) { create(:admin, roles: [admin_role]) }

        before do
          fake_login_admin(admin)
        end

        it "deletes the known issue" do
          delete :destroy, params: { id: known_issue.id }
          expect { known_issue.reload }
            .to raise_exception(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
