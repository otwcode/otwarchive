require "spec_helper"

describe PreferencesController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "GET #index" do
    context "as regular user" do
      before { fake_login_known_user(user) }

      it "assigns user and preference" do
        get :index, params: { user_id: user.login }
        expect(assigns(:user)).to eq(user)
        expect(assigns(:preference)).to eq(user.preference)
        expect(response).to be_successful
      end

      it "disallows viewing others' preferences" do
        get :index, params: { user_id: other_user.login }

        it_redirects_to_with_error(user_path(other_user), "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "as admin" do
      read_roles = %w[superadmin policy_and_abuse support]

      before { fake_login_admin(admin) }

      context "with no role" do
        let(:admin) { create(:admin, roles: []) }
        
        it "redirects with an error" do
          get :index, params: { user_id: user.login }

          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end
      end

      (Admin::VALID_ROLES - read_roles).each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "redirects with an error" do
            get :index, params: { user_id: user.login }

            it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
          end
        end
      end

      read_roles.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "assigns user and preference" do
            get :index, params: { user_id: user.login }
          
            expect(assigns(:user)).to eq(user)
            expect(assigns(:preference)).to eq(user.preference)
            expect(response).to be_successful            
          end
        end
      end
    end
  end

  describe "PUT #update" do
    context "as regular user" do
      before { fake_login_known_user(user) }

      let(:skin) { create(:work_skin, :public) }

      it "allows users to update all preferences" do
        put :update, params: {
          user_id: user.login,
          id: user.preference.id,
          preference: {
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
        }

        it_redirects_to_with_notice(user_path(user), "Your preferences were successfully updated.")
      end

      it "renders index on failed save" do
        allow_any_instance_of(Preference).to receive(:save).and_return(false)
        
        put :update, params: { user_id: user.login, id: user.preference.id, preference: { minimize_search_engines: true } }
        
        expect(response).to render_template(:index)
        expect(flash[:error]).to eq("Sorry, something went wrong. Please try that again.")
      end
    end

    context "as admin" do
      Admin::VALID_ROLES.each do |role|
        context "with role #{role}" do
          let(:admin) { create(:admin, roles: [role]) }

          it "cannot edit preferences" do
            put :update, params: { user_id: user.login, id: user.preference.id, preference: { minimize_search_engines: true } }
          
            it_redirects_to_with_error(user_path(user), "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          end
        end
      end
    end
  end
end
