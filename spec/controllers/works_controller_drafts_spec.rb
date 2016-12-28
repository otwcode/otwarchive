require 'spec_helper'

describe WorksController do
  include LoginMacros

  describe "drafts" do
    let(:drafts_user) { create(:user) }
    let!(:visiting_user_pseud) { create(:pseud, name: "Visiting User Pseud") }
    let!(:visiting_user) {
      user = create(:user)
      user.pseuds << visiting_user_pseud
      user
    }

    before do
      fake_login_known_user(visiting_user)
    end

    context "no user_id" do
      it "should redirect to the user controller" do
        get :drafts
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to users_path
      end

      it "should display an appropriate error message" do
        get :drafts
        expect(flash[:error]).to start_with "Whose drafts did you want to look at?"
      end
    end

    context "with a valid user_id" do

      context "if the user_id requested doesn't belong to the current user" do
        it "should display an error" do
          get :drafts, user_id: drafts_user.login
          expect(flash[:error]).to eq "You can only see your own drafts, sorry!"
        end

        it "should redirect to the current user's dashboard" do
          get :drafts, user_id: drafts_user.login
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to user_path(visiting_user)
        end
      end

      context "if the user_id is that of the current user" do
        let!(:default_pseud_work) {
          create(:work, authors: [visiting_user.default_pseud], posted: false, title: "Default pseud work")
        }
        let!(:other_pseud_work) {
          create(:work, authors: [visiting_user_pseud], posted: false, title: "Other pseud work")
        }

        it "should display no errors" do
          get :drafts, user_id: visiting_user.login
          expect(flash[:error]).to be_nil
        end

        it "should display all the user's drafts if no pseud_id is specified" do
          get :drafts, user_id: visiting_user.login
          expect(assigns(:works)).to include(other_pseud_work)
          expect(assigns(:works)).to include(default_pseud_work)
        end

        it "should display only the drafts for a specific pseud if a pseud_id is specified" do
          get :drafts, user_id: visiting_user.login, pseud_id: visiting_user_pseud.name
          expect(assigns(:works)).to include(other_pseud_work)
          expect(assigns(:works)).not_to include(default_pseud_work)
        end
      end
    end
  end
end
