# frozen_string_literal: true

require "spec_helper"

describe ArchiveFaqsController do
  include LoginMacros
  include RedirectExpectationHelper

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
