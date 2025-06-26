# frozen_string_literal: true

require "spec_helper"

describe ArchiveFaqsController do
  include LoginMacros
  include RedirectExpectationHelper

  fully_authorized_roles = %w[superadmin docs support]

  shared_examples "an action only fully authorized admins can access" do
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - fully_authorized_roles).each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    fully_authorized_roles.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  translation_authorized_roles = %w[superadmin docs support translation]

  shared_examples "an action translation authorized admins can access" do
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    (Admin::VALID_ROLES - translation_authorized_roles).each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end
    end

    translation_authorized_roles.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "succeeds" do
          subject
          success
        end
      end
    end
  end

  shared_examples "a non-English action that nobody can access" do
    before { fake_login_admin(admin) }

    context "with no role" do
      let(:admin) { create(:admin, roles: []) }

      it "redirects with an error" do
        subject
        it_redirects_to_with_error(archive_faqs_path, "Sorry, this action is only available for English FAQs.")
      end
    end

    Admin::VALID_ROLES.each do |role|
      context "with role #{role}" do
        let(:admin) { create(:admin, roles: [role]) }

        it "redirects with an error" do
          subject
          it_redirects_to_with_error(archive_faqs_path, "Sorry, this action is only available for English FAQs.")
        end
      end
    end
  end

  let(:non_standard_locale) { create(:locale) }
  let(:user_locale) { create(:locale) }
  let(:user) do
    user = create(:user)
    user.preference.update!(locale: user_locale)
    user
  end

  describe "GET #index" do
    context "when there's no locale in session" do
      it "redirects to the default locale when the locale param is invalid" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "eldritch" }
        it_redirects_to(archive_faqs_path(language_id: I18n.default_locale))
      end

      it "redirects to the default locale when the locale param is empty" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "" }
        it_redirects_to(archive_faqs_path(language_id: I18n.default_locale))
      end

      it "redirects to the default locale when the locale param and the session locale are _explicty_ empty (legacy session behavior)" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "" }, session: { language_id: "" }
        it_redirects_to(archive_faqs_path(language_id: "en"))
      end
    end

    context "when logged in as a regular user" do
      before { fake_login_known_user(user) }

      context "when the set locale preference feature flag is off" do
        before { $rollout.deactivate_user(:set_locale_preference, user) }

        it "redirects to the default locale when the locale param is invalid" do
          expect(I18n).not_to receive(:with_locale)
          get :index, params: { language_id: "eldritch" }
          it_redirects_to(archive_faqs_path(language_id: I18n.default_locale))
        end
      end

      context "when the set locale preference feature flag is on" do
        before { $rollout.activate_user(:set_locale_preference, user) }

        it "redirects to the user preferred locale when the locale param is invalid" do
          expect(I18n).not_to receive(:with_locale)
          get :index, params: { language_id: "eldritch" }
          it_redirects_to(archive_faqs_path(language_id: user_locale.iso))
        end
      end
    end

    context "when logged in as an admin" do
      before { fake_login_admin(create(:admin)) }

      it "redirects to the default locale with an error message when the locale param is invalid" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "eldritch" }
        it_redirects_to_with_error(archive_faqs_path(language_id: I18n.default_locale),
                                   "The specified locale does not exist.")
      end
    end

    context "when there's a locale in session" do
      before do
        get :index, params: { language_id: non_standard_locale.iso }
        expect(response).to render_template(:index)
        expect(session[:language_id]).to eq(non_standard_locale.iso)
      end

      it "redirects to the previous locale when the locale param is empty" do
        get :index
        it_redirects_to(archive_faqs_path(language_id: non_standard_locale.iso))
      end

      it "redirects to the previous locale when the locale param is invalid" do
        get :index, params: { language_id: "eldritch" }
        it_redirects_to(archive_faqs_path(language_id: non_standard_locale.iso))
      end

      context "when logged in as a regular user" do
        before do
          fake_login_known_user(user)
        end

        it "still redirects to the previous locale when the locale param is invalid" do
          get :index, params: { language_id: "eldritch" }
          it_redirects_to(archive_faqs_path(language_id: non_standard_locale.iso))
        end

        context "with set_locale_preference" do
          before { $rollout.activate_user(:set_locale_preference, user) }

          it "still redirects to the previous locale when the locale param is invalid" do
            get :index, params: { language_id: "eldritch" }
            it_redirects_to(archive_faqs_path(language_id: non_standard_locale.iso))
          end
        end
      end
    end
  end

  describe "GET #show" do
    it "raises a 404 for an invalid id" do
      params = { id: "angst", language_id: "en" }
      expect { get :show, params: params }
        .to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH #update" do
    let(:faq) { create(:archive_faq) }

    context "when logged in as an admin" do
      before { fake_login_admin(create(:admin)) }

      it "redirects to the default locale when the locale param is empty" do
        expect(I18n).not_to receive(:with_locale)
        patch :update, params: { id: faq.id, language_id: "" }
        it_redirects_to(archive_faq_path(id: faq.id, language_id: I18n.default_locale))
      end

      it "redirects to the default locale with an error message when the locale param is invalid" do
        expect(I18n).not_to receive(:with_locale)
        patch :update, params: { id: faq.id, language_id: "eldritch" }
        it_redirects_to_with_error(archive_faq_path(id: faq.id, language_id: I18n.default_locale),
                                   "The specified locale does not exist.")
      end
    end

    subject { patch :update, params: { id: faq, archive_faq: { title: "Changed" }, language_id: locale } }
    let(:success) do
      I18n.with_locale(locale) do
        expect { faq.reload }
          .to change { faq.title }
      end
      it_redirects_to_with_notice(faq, "Archive FAQ was successfully updated.")
    end

    context "for the default locale" do
      let(:locale) { "en" }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "an action translation authorized admins can access"
    end
  end

  describe "GET #edit" do
    subject { get :edit, params: { id: faq, language_id: locale } }
    let(:faq) { create(:archive_faq) }
    let(:success) do
      expect(response).to render_template(:edit)
    end

    context "for the default locale" do
      let(:locale) { "en" }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "an action translation authorized admins can access"
    end
  end

  describe "GET #new" do
    subject { get :new, params: { language_id: locale } }
    let(:success) do
      expect(response).to render_template(:new)
    end

    context "for the default locale" do
      let(:locale) { "en" }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end

  describe "POST #create" do
    subject { post :create, params: { archive_faq: attributes_for(:archive_faq), language_id: locale } }
    let(:success) do
      expect(ArchiveFaq.count).to eq(1)
      it_redirects_to_with_notice(assigns[:archive_faq], "Archive FAQ was successfully created.")
    end

    context "for the default locale" do
      let(:locale) { I18n.default_locale }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end

  describe "GET #manage" do
    subject { get :manage, params: { language_id: locale } }
    let(:success) do
      expect(response).to render_template(:manage)
    end

    context "for the default locale" do
      let(:locale) { "en" }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end

  describe "POST #update_positions" do
    subject { post :update_positions, params: { archive_faqs: [3, 1, 2], language_id: locale } }
    let!(:faq1) { create(:archive_faq, position: 1) }
    let!(:faq2) { create(:archive_faq, position: 2) }
    let!(:faq3) { create(:archive_faq, position: 3) }
    let(:success) do
      expect(faq1.reload.position).to eq(3)
      expect(faq2.reload.position).to eq(1)
      expect(faq3.reload.position).to eq(2)
      it_redirects_to_with_notice(archive_faqs_path, "Archive FAQs order was successfully updated.")
    end

    context "for the default locale" do
      let(:locale) { I18n.default_locale }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end

  describe "GET #confirm_delete" do
    subject { get :confirm_delete, params: { id: faq, language_id: locale } }
    let(:faq) { create(:archive_faq) }
    let(:success) do
      expect(response).to render_template(:confirm_delete)
    end

    context "for the default locale" do
      let(:locale) { "en" }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end

  describe "DELETE #destroy" do
    subject { delete :destroy, params: { id: faq, language_id: locale } }
    let(:faq) { create(:archive_faq) }
    let(:success) do
      expect { faq.reload }
        .to raise_exception(ActiveRecord::RecordNotFound)
      it_redirects_to(archive_faqs_path)
    end

    context "for the default locale" do
      let(:locale) { I18n.default_locale }
      it_behaves_like "an action only fully authorized admins can access"
    end

    context "for a non-default locale" do
      let(:locale) { non_standard_locale.iso }
      it_behaves_like "a non-English action that nobody can access"
    end
  end
end
