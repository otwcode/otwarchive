require "spec_helper"

describe ChallengeRequestsController, bookmark_search: true, collection_search: true, work_search: true do 
  include LoginMacros
  include RedirectExpectationHelper

  describe "index" do
    context "when there are anonymous prompts" do
      render_views

      it "does not throw a 500 error if sorting by prompter with an anonymous prompt" do
        signup = create(:prompt_meme_signup)  
        signup.requests.create(anonymous: true)
        run_all_indexing_jobs
        get :index, params: { collection_id: signup.collection.name, sort_column: "prompter" }
        expect(response.status).not_to eq(500)
      end
    end

    context "with gift exchanges where request summary is private" do
      let(:challenge) { create(:gift_exchange, requests_summary_visible: false) }
      let(:collection) { create(:collection, challenge: challenge) }

      it "allows support admins to view the requests summary" do
        fake_login_admin(create(:support_admin))

        get :index, params: { collection_id: collection.name }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end

      it "does not allow admins with other roles to view the requests summary" do
        fake_login_admin(create(:tag_wrangling_admin))

        get :index, params: { collection_id: collection.name }

        it_redirects_to_with_notice(collection_path(collection), "You are not allowed to view the requests summary!")
      end
    end
  end
end
