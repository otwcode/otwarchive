# frozen_string_literal: true

require "spec_helper"

describe ArchiveFaqsController do
  include LoginMacros
  include RedirectExpectationHelper

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

      it "redirects to the default locale when the locale param and the session locale are empty" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "" }, session: { language_id: "" }
        it_redirects_to(archive_faqs_path(language_id: "en"))
      end
    end

    context "when logged in as a regular user" do
      before { fake_login }

      it "renders the index page of the user preferred locale when the locale param is invalid" do
        expect(I18n).not_to receive(:with_locale)
        get :index, params: { language_id: "eldritch" }
        it_redirects_to(archive_faqs_path(language_id: "en"))
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
      let(:locale) { create(:locale) }

      before do
        get :index, params: { language_id: locale.iso }
        expect(response).to render_template(:index)
        expect(session[:language_id]).to eq(locale.iso)
      end

      it "redirects to the previous locale when the locale param is empty" do
        get :index
        it_redirects_to(archive_faqs_path(language_id: locale.iso))
      end

      it "redirects to the previous locale when the locale param is invalid" do
        get :index, params: { language_id: "eldritch" }
        it_redirects_to(archive_faqs_path(language_id: locale.iso))
      end
    end
  end

  describe "GET #show" do
    it "raises a 404 for an invalid id" do
      params = { id: "angst", language_id: "en" }
      expect { get :show, params: params }.to raise_error ActiveRecord::RecordNotFound
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
  end
end
