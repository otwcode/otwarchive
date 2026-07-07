require "spec_helper"

describe LocaleLanguagesController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "GET #index" do
    context "when not logged in" do
      it "redirects with error" do
        get :index
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as user" do
      it "redirects with error" do
        fake_login
        get :index

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation support policy_and_abuse]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          get :index

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin support policy_and_abuse].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "renders the index template" do
          fake_login_admin(admin)
          get :index
          expect(response).to render_template("index")
        end
      end
    end
  end

  describe "GET #new" do
    context "when not logged in" do
      it "redirects with error" do
        get :new
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as user" do
      it "redirects with error" do
        fake_login
        get :new

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          get :new
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "renders the new template" do
          fake_login_admin(admin)
          get :new
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "POST #create" do
    let(:locale_language_params) do
      {
        locale_language: {
          name: "Test",
          short: "ts",
          support_available: "0",
          abuse_support_available: "0",
          sortable_name: "ts"
        }
      }
    end

    context "when not logged in" do
      it "redirects with error" do
        post :create, params: locale_language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as user" do
      it "redirects with error" do
        fake_login
        post :create, params: locale_language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          post :create, params: locale_language_params

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        before do
          fake_login_admin(admin)
          post :create, params: locale_language_params
        end

        it "creates the new locale language" do
          new_lang = LocaleLanguage.last
          expect(new_lang.name).to eq("Test")
          expect(new_lang.short).to eq("ts")
          expect(new_lang.support_available).to be false
          expect(new_lang.abuse_support_available).to be false
          expect(new_lang.sortable_name).to eq("ts")
        end

        it "redirects to locale_languages_path with notice" do
          it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully added.")
        end
      end
    end

    context "when validation fails" do
      let(:admin) { create(:admin, roles: ["translation"]) }

      it "renders new" do
        fake_login_admin(admin)
        post :create, params: { locale_language: { name: "", short: "" } }
        expect(response).to render_template("new")
      end
    end
  end

  describe "GET #edit" do
    let(:finnish) { create(:locale_language, name: "Suomi", short: "fi", support_available: "0", abuse_support_available: "1") }

    context "when not logged in" do
      it "redirects with error" do
        get :edit, params: { id: finnish.short }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as user" do
      it "redirects with error" do
        fake_login
        get :edit, params: { id: finnish.short }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when the locale language does not exist" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "raises RecordNotFound" do
        fake_login_admin(admin)
        expect do
          get :edit, params: { id: "nonexistent" }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation support policy_and_abuse]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          get :edit, params: { id: finnish.short }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin support policy_and_abuse].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "renders the edit template" do
          fake_login_admin(admin)
          get :edit, params: { id: finnish.short }
          expect(response).to render_template("edit")
        end
      end
    end

    context "when the locale language is the default" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "redirects with error" do
        fake_login_admin(admin)
        get :edit, params: { id: LocaleLanguage.default.short }
        it_redirects_to_with_error(locale_languages_path, "Sorry, you can't edit the default locale language.")
      end
    end
  end

  describe "PUT #update" do
    let(:finnish) { create(:locale_language, name: "Suomi", short: "fi", support_available: "0", abuse_support_available: "1") }
    let(:locale_language_params) do
      {
        id: finnish.short,
        locale_language: {
          name: "Suomi",
          short: "fi",
          support_available: "1",
          abuse_support_available: "0",
          sortable_name: "su"
        }
      }
    end

    let(:locale_language_params_support) do
      {
        id: finnish.short,
        locale_language: {
          support_available: "1"
        }
      }
    end

    let(:locale_language_params_abuse) do
      {
        id: finnish.short,
        locale_language: {
          abuse_support_available: "0"
        }
      }
    end

    context "when not logged in" do
      it "redirects with error" do
        put :update, params: locale_language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when logged in as user" do
      it "redirects with error" do
        fake_login
        put :update, params: locale_language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    context "when the locale language does not exist" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "raises RecordNotFound" do
        fake_login_admin(admin)
        expect do
          put :update, params: { id: "nonexistent", locale_language: { name: "X" } }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation support policy_and_abuse]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          put :update, params: locale_language_params

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        before do
          fake_login_admin(admin)
          put :update, params: locale_language_params
        end

        it "updates the locale language" do
          finnish.reload
          expect(finnish.name).to eq("Suomi")
          expect(finnish.short).to eq("fi")
          expect(finnish.support_available).to eq(true)
          expect(finnish.abuse_support_available).to eq(false)
          expect(finnish.sortable_name).to eq("su")
        end

        it "redirects and returns success message" do
          it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully updated.")
        end
      end
    end

    context "when logged in as an admin with policy_and_abuse role and attempting to edit non-abuse fields" do
      let(:admin) { create(:admin, roles: ["policy_and_abuse"]) }

      before do
        fake_login_admin(admin)
      end

      it "raises an error and does not update non-abuse fields" do
        expect do
          put :update, params: locale_language_params
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.support_available).to be false
        expect(finnish.abuse_support_available).to be true
      end
    end

    context "when logged in as an admin with policy_and_abuse role and updating abuse_support_available" do
      let(:admin) { create(:admin, roles: ["policy_and_abuse"]) }

      before do
        fake_login_admin(admin)
        put :update, params: locale_language_params_abuse
      end

      it "updates the locale language" do
        finnish.reload
        expect(finnish.abuse_support_available).to eq(false)
      end

      it "redirects and returns success message" do
        it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully updated.")
      end
    end

    context "when logged in as an admin with support role and attempting to edit non-support fields" do
      let(:admin) { create(:admin, roles: ["support"]) }

      before do
        fake_login_admin(admin)
      end

      it "raises an error and does not update non-support fields" do
        expect do
          put :update, params: locale_language_params
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.support_available).to be false
        expect(finnish.abuse_support_available).to be true
      end
    end

    context "when logged in as an admin with support role and updating support_available" do
      let(:admin) { create(:admin, roles: ["support"]) }

      before do
        fake_login_admin(admin)
        put :update, params: locale_language_params_support
      end

      it "updates the locale language" do
        finnish.reload
        expect(finnish.support_available).to eq(true)
      end

      it "redirects and returns success message" do
        it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully updated.")
      end
    end

    context "when validation fails" do
      let(:admin) { create(:admin, roles: ["translation"]) }

      it "renders edit" do
        fake_login_admin(admin)
        put :update, params: { id: finnish.short, locale_language: { name: "", short: "" } }
        expect(response).to render_template("edit")
      end
    end
  end
end
