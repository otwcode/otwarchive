require "spec_helper"

describe PreferencesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user_skin) { create(:skin) }
  let(:user) { user_skin.author }
  let(:other_user) { create(:user) }

  describe "GET #index" do
    context "as regular user" do
      before { fake_login_known_user(user) }

      it "assigns user and preference" do
        get :index, params: { user_id: user.login }
        expect(assigns(:user)).to eq(user)
        expect(assigns(:preference)).to eq(user.preference)
        expect(assigns(:available_skins)).to include(user_skin)
        expect(response).to be_successful
      end

      it "disallows accessing others' preferences" do
        get :index, params: { user_id: other_user.login }

        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "as a guest" do
      it "disallows accessing others' preferences" do
        get :index, params: { user_id: user.login }

        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "as admin" do
      subject { get :index, params: { user_id: user.login } }

      let(:success) do
        expect(assigns(:user)).to eq(user)
        expect(assigns(:preference)).to eq(user.preference)
        expect(assigns(:available_skins)).to include(user_skin)
        expect(response).to be_successful     
      end

      read_roles = %w[superadmin policy_and_abuse support]

      it_behaves_like "an action only authorized admins can access", authorized_roles: read_roles
    end
  end

  describe "PUT #update" do
    let(:skin) { create(:skin, :public) }

    let(:preference_params) do
      {
        minimize_search_engines: "0",
        disable_share_links: "0",
        allow_cocreator: "0",
        adult: "0",
        view_full_works: "0",
        hide_warnings: "0",
        hide_freeform: "0",
        disable_work_skins: "0",
        skin_id: skin.id,
        time_zone: "UTC",
        work_title_format: "TITLE-AUTHOR-FANDOM",
        comment_emails_off: "0",
        comment_inbox_off: "0",
        comment_copy_to_self_off: "0",
        kudos_emails_off: "0",
        guest_replies_off: "0",
        allow_collection_invitation: "0",
        allow_gifts: "0",
        collection_emails_off: "0",
        collection_inbox_off: "0",
        recipient_emails_off: "0",
        history_enabled: "0",
        first_login: "0",
        banner_seen: "0"
      }
    end

    context "as regular user" do
      before { fake_login_known_user(user) }

      it "allows users to update all preferences" do
        put :update, params: {
          user_id: user.login,
          id: user.preference.id,
          preference: preference_params
        }

        it_redirects_to_with_notice(user_path(user), "Your preferences were successfully updated.")
      end

      it "disallows editing others' preferences" do
        put :update, params: {
          user_id: other_user.login,
          id: other_user.preference.id,
          preference: preference_params
        }

        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "renders index on failed save" do
        allow_any_instance_of(Preference).to receive(:save).and_return(false)
        
        put :update, params: { user_id: user.login, id: user.preference.id, preference: { minimize_search_engines: true } }
        
        expect(response).to render_template(:index)
        expect(flash[:error]).to eq("Sorry, something went wrong. Please try that again.")
      end
    end

    context "as a guest" do
      it "disallows editing others' preferences" do
        put :update, params: {
          user_id: user.login,
          id: user.preference.id,
          preference: preference_params
        }

        it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "as admin" do
      subject { put :update, params: { user_id: user.login, id: user.preference.id, preference: preference_params } }
      
      it_behaves_like "an action only authorized admins can access", authorized_roles: []
    end
  end
end
