require "spec_helper"

describe LocalesController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:translation_admin) { create(:translation_admin) }

  describe "GET #index" do
    it "displays the default locale" do
      get :index
      expect(response).to render_template("index")
      expect(assigns(:locales)).to eq([Locale.default])
    end
  end

  describe "GET #new" do
    context "when logged in as a translation admin" do
      before { fake_login_known_user(translation_admin) }

      it "displays the form to create a locale" do
        get :new
        expect(response).to render_template("new")
        expect(assigns(:languages)).to eq(Language.default_order)
        expect(assigns(:locale)).to be_a_new(Locale)
      end
    end
  end

  describe "GET #edit" do
    context "when logged in as a translation admin" do
      let(:locale) { create(:locale) }

      before { fake_login_known_user(translation_admin) }

      it "displays the form to update a locale" do
        get :edit, params: { id: locale.iso }
        expect(response).to render_template("edit")
        expect(assigns(:locale)).to eq(locale)
        expect(assigns(:languages)).to eq(Language.default_order)
      end
    end
  end

  describe "PUT #update" do
    context "when logged in as a non-admin" do
      before { fake_login_known_user(user) }

      it "redirects to the user page with an error" do
        put :update, params: { id: 0 }
        it_redirects_to_with_error(user_path(user),
                                   "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as a translation admin" do
      let(:locale) { create(:locale) }

      before { fake_login_known_user(translation_admin) }

      it "updates an existing locale" do
        params = { name: "Tiếng Việt", email_enabled: true }

        put :update, params: { id: locale.iso, locale: params }
        it_redirects_to_with_notice(locales_path, "Your locale was successfully updated.")

        locale.reload
        expect(locale.name).to eq(params[:name])
        expect(locale.email_enabled).to eq(params[:email_enabled])
      end

      it "redirects to the edit form for the same locale if the new iso is not unique" do
        put :update, params: { id: locale.iso, locale: { iso: Locale.default.iso } }
        expect(response).to render_template("edit")
        expect(assigns(:locale)).to eq(locale)
        expect(assigns(:languages)).to eq(Language.default_order)
      end
    end
  end

  describe "POST #create" do
    context "when logged in as a non-admin" do
      before { fake_login_known_user(user) }

      it "redirects to the user page with an error" do
        post :create
        it_redirects_to_with_error(user_path(user),
                                   "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as a translation admin" do
      before { fake_login_known_user(translation_admin) }

      it "adds a new locale and redirects to list of locales" do
        params = {
          name: "Español", iso: "es", language_id: Language.default.id,
          email_enabled: true, interface_enabled: false,
        }

        post :create, params: { locale: params }
        it_redirects_to_with_notice(locales_path, "Locale was successfully added.")

        locale = Locale.last
        expect(locale.iso).to eq(params[:iso])
        expect(locale.name).to eq(params[:name])
        expect(locale.language.id).to eq(params[:language_id])
        expect(locale.email_enabled).to eq(params[:email_enabled])
        expect(locale.interface_enabled).to eq(params[:interface_enabled])
      end

      it "renders the create form if iso is missing" do
        params = {
          name: "Español", language_id: Language.default.id,
          email_enabled: true, interface_enabled: false,
        }

        post :create, params: { locale: params }
        expect(response).to render_template("new")
        expect(assigns(:languages)).to eq(Language.default_order)
        expect(Locale.last).to eq(Locale.default)
      end
    end
  end
end
