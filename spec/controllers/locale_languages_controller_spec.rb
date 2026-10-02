require "spec_helper"

describe LocaleLanguagesController do
  include LoginMacros
  include RedirectExpectationHelper

  full_access_roles = %w[superadmin translation support policy_and_abuse].freeze

  describe "GET #index" do
    subject { get :index }

    let(:success) do
      expect(response).to render_template("index")
    end

    it_behaves_like "an action that non-admins cannot access"
    it_behaves_like "an action only authorized admins can access",
                    authorized_roles: full_access_roles
  end

  describe "GET #new" do
    subject { get :new }

    let(:success) do
      expect(response).to render_template("new")
    end

    it_behaves_like "an action that non-admins cannot access"
    it_behaves_like "an action only authorized admins can access",
                    authorized_roles: %w[superadmin translation]
  end

  describe "POST #create" do
    subject { post :create, params: locale_language_params }

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

    let(:success) do
      it_redirects_to_with_notice(
        locale_languages_path, "Locale language was successfully added."
      )
    end

    it_behaves_like "an action that non-admins cannot access"
    it_behaves_like "an action only authorized admins can access",
                    authorized_roles: %w[superadmin translation]

    context "when logged in as an authorized admin" do
      let(:admin) { create(:admin, roles: ["translation"]) }

      before { fake_login_admin(admin) }

      it "creates the new locale language" do
        subject

        new_lang = LocaleLanguage.last
        expect(new_lang.name).to eq("Test")
        expect(new_lang.short).to eq("ts")
        expect(new_lang.support_available).to be false
        expect(new_lang.abuse_support_available).to be false
        expect(new_lang.sortable_name).to eq("ts")
      end

      context "when validation fails" do
        let(:locale_language_params) do
          { locale_language: { name: "", short: "" } }
        end

        it "renders new" do
          subject
          expect(response).to render_template("new")
        end
      end
    end
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: finnish.short } }

    let(:finnish) do
      create(:locale_language, name: "Suomi", short: "fi",
                               support_available: "0",
                               abuse_support_available: "1")
    end

    let(:success) do
      expect(response).to render_template("edit")
    end

    it_behaves_like "an action that non-admins cannot access"
    it_behaves_like "an action only authorized admins can access",
                    authorized_roles: full_access_roles

    context "when the locale language is missing and the admin is authorized" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "raises RecordNotFound" do
        fake_login_admin(admin)
        expect do
          get :edit, params: { id: "nonexistent" }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "when editing the default and the admin is authorized" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "redirects with error" do
        fake_login_admin(admin)
        get :edit, params: { id: LocaleLanguage.default.short }
        it_redirects_to_with_error(locale_languages_path, "Sorry, you can't edit the default locale language.")
      end
    end
  end

  describe "PUT #update" do
    subject { put :update, params: locale_language_params }

    let(:finnish) do
      create(:locale_language, name: "Suomi", short: "fi",
                               support_available: "0",
                               abuse_support_available: "1")
    end
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

    it_behaves_like "an action that non-admins cannot access"

    context "when the locale language is missing and the admin is authorized" do
      let(:admin) { create(:admin, roles: ["superadmin"]) }

      it "raises RecordNotFound" do
        fake_login_admin(admin)
        expect do
          put :update, params: { id: "nonexistent", locale_language: { name: "X" } }
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    (Admin::VALID_ROLES - full_access_roles).each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with error" do
          fake_login_admin(admin)
          subject

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    %w[translation superadmin].each do |role|
      context "when logged in as an admin with #{role} role" do
        let(:admin) { create(:admin, roles: [role]) }

        before do
          fake_login_admin(admin)
          subject
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
          it_redirects_to_with_notice(
            locale_languages_path, "Locale language was successfully updated."
          )
        end
      end
    end

    context "when logged in as an admin with policy_and_abuse role" do
      let(:admin) { create(:admin, roles: ["policy_and_abuse"]) }

      before { fake_login_admin(admin) }

      it "raises an error and does not update non-abuse fields" do
        expect do
          subject
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.support_available).to be false
        expect(finnish.abuse_support_available).to be true
      end

      context "when updating abuse_support_available" do
        let(:locale_language_params) do
          { id: finnish.short,
            locale_language: { abuse_support_available: "0" } }
        end

        before { subject }

        it "updates the locale language" do
          finnish.reload
          expect(finnish.abuse_support_available).to eq(false)
        end

        it "redirects and returns success message" do
          it_redirects_to_with_notice(
            locale_languages_path, "Locale language was successfully updated."
          )
        end
      end
    end

    context "when logged in as an admin with support role" do
      let(:admin) { create(:admin, roles: ["support"]) }

      before { fake_login_admin(admin) }

      it "raises an error and does not update non-support fields" do
        expect do
          subject
        end.to raise_exception(ActionController::UnpermittedParameters)
        finnish.reload
        expect(finnish.name).to eq("Suomi")
        expect(finnish.support_available).to be false
        expect(finnish.abuse_support_available).to be true
      end

      context "when updating support_available" do
        let(:locale_language_params) do
          { id: finnish.short, locale_language: { support_available: "1" } }
        end

        before { subject }

        it "updates the locale language" do
          finnish.reload
          expect(finnish.support_available).to eq(true)
        end

        it "redirects and returns success message" do
          it_redirects_to_with_notice(
            locale_languages_path, "Locale language was successfully updated."
          )
        end
      end
    end

    context "when validation fails and the admin is authorized" do
      let(:admin) { create(:admin, roles: ["translation"]) }
      let(:locale_language_params) do
        { id: finnish.short, locale_language: { name: "", short: "" } }
      end

      it "renders edit" do
        fake_login_admin(admin)
        subject
        expect(response).to render_template("edit")
      end
    end
  end
end
