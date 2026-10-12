require "spec_helper"

describe StatsController do
  include RedirectExpectationHelper
  include LoginMacros

  describe "GET #index" do
    let!(:stats_user) { create(:user) }
    let!(:work) { create(:work, authors: [stats_user.default_pseud]) }

    it "errors if user does not exist" do
      expect do
        get :index, params: { user_id: "non_existent_user" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "redirects to user page when not logged in and displays an error" do
      get :index, params: { user_id: stats_user.login }
      it_redirects_to_with_error(user_path(stats_user),
                                 "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
    end

    it "redirects to user page when logged in as another user and displays an error" do
      fake_login_known_user(create(:user))
      get :index, params: { user_id: stats_user.login }
      it_redirects_to_with_error(user_path(stats_user),
                                 "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    it "renders the stats page when logged in as the correct user" do
      fake_login_known_user(stats_user)
      get :index, params: { user_id: stats_user.login }
      expect(response).to render_template("index")
      expect(assigns(:page_subtitle)).to eq("#{stats_user.login} - Stats")
    end
  end
end
