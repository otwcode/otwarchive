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

  describe "GET new" do
    context "when not logged in" do
      it "redirects with error" do
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

  describe "POST create" do
    let(:language_params) do 
      {
        locale_language: {
          name: "Test",
          short: "ts",
          support_available: false,
          abuse_support_available: false,
          sortable_name: "ts"
        }
      }
    end

    context "when not logged in" do
      it "redirects with error" do
        post :create, params: language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }
        
        it "redirects with error" do
          fake_login_admin(admin)
          post :create, params: language_params

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }
        
        before do
          fake_login_admin(admin)
          post :create, params: language_params
        end

        it "creates the new locale language" do
          new_lang = LocaleLanguage.last
          expect(new_lang.name).to eq("Test")
          expect(new_lang.short).to eq("ts")
          expect(new_lang.support_available).to eq(false)
          expect(new_lang.abuse_support_available).to eq(false)
          expect(new_lang.sortable_name).to eq("ts")
        end

        it "redirects to locale_languages_path with notice" do
          it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully added.")
        end
      end
    end
  end

  describe "GET edit" do
    let(:finnish) { LocaleLanguage.create(name: "Suomi", short: "fi", support_available: "0", abuse_support_available: "1") }

    context "when not logged in" do
      it "redirects with error" do
        get :edit, params: { id: finnish.short, locale_language: {} }

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end
    
    (Admin::VALID_ROLES - %w[superadmin translation support policy_and_abuse]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }
        
        it "redirects with error" do
          fake_login_admin(admin)
          get :edit, params: { id: finnish.short, locale_language: {} }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin support policy_and_abuse].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "renders the edit template" do
          fake_login_admin(admin)
          get :edit, params: { id: finnish.short, locale_language: {} }
          expect(response).to render_template("edit")
        end
      end
    end
  end

  describe "PUT update" do
    let(:finnish) { LocaleLanguage.create(name: "Suomi", short: "fi", support_available: "0", abuse_support_available: "1") }
    let(:language_params) do 
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

    let(:language_params_support) do 
      {
        id: finnish.short,
        locale_language: {
          name: "Suomi",
          short: "fi",
          support_available: "1",
          sortable_name: ""
        }
      }
    end

    let(:language_params_abuse) do 
      {
        id: finnish.short,
        locale_language: {
          abuse_support_available: "0"
        }
      }
    end
    
    context "when not logged in" do
      it "redirects with error" do
        put :update, params: language_params

        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - %w[superadmin translation support policy_and_abuse]).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }
        
        it "redirects with error" do
          fake_login_admin(admin)
          put :update, params: language_params

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        before do
          fake_login_admin(admin)
          put :update, params: language_params
        end

        it "updates the language" do
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

    
    context "when logged in as an admin with policy_and_abuse role and I attempt to edit a non-abuse field" do
      let(:admin) { create(:admin, roles: ["policy_and_abuse"]) }
      before do
        fake_login_admin(admin)
      end
      it "throws error and doesn't save changes to non-abuse field" do
        expect do 
          put :update, params: language_params
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.support_available).to eq(false)
      end
    end 

    context "when logged in as an admin with policy_and_abuse role and attempt to edit abuse_support_available field" do
      let(:admin) { create(:admin, roles: ["policy_and_abuse"]) }
      
      before do
        fake_login_admin(admin)
        put :update, params: language_params_abuse
      end
      it "updates the language" do
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.short).to eq("fi")
        expect(finnish.support_available).to eq(false)
        expect(finnish.abuse_support_available).to eq(false)
        expect(finnish.sortable_name).to eq("")
      end

      it "redirects and returns success message" do
        it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully updated.")
      end
    end 
    
    context "when logged in as an admin with support role and attempt to edit abuse_support_available field" do
      let(:admin) { create(:admin, roles: ["support"]) }
      before do
        fake_login_admin(admin)
      end
      it "throws error and doesn't save changes to abuse_support_available field" do
        expect do 
          put :update, params: language_params
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.abuse_support_available).to eq(true)
      end
    end 

    context "when logged in as an admin with support role and attempt to edit non-abuse fields" do
      let(:admin) { create(:admin, roles: ["support"]) }
      before do
        fake_login_admin(admin)
        put :update, params: language_params_support
      end
      it "updates the language" do
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.short).to eq("fi")
        expect(finnish.support_available).to eq(true)
        expect(finnish.abuse_support_available).to eq(true)
        expect(finnish.sortable_name).to eq("")
      end

      it "redirects and returns success message" do
        it_redirects_to_with_notice(locale_languages_path, "Locale language was successfully updated.")
      end
    end 
  end
end
