require "spec_helper"

describe ChallengeRequestsController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "index" do
    context "when there are anonymous prompts", bookmark_search: true, collection_search: true, work_search: true do
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
      authorized_roles = %w[support policy_and_abuse superadmin].freeze
      let(:challenge) { create(:gift_exchange, requests_summary_visible: false) }
      let(:collection) { create(:collection, challenge: challenge) }

      subject { get :index, params: { collection_id: collection.name } }

      let(:success) do
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end

      it_behaves_like "an action only authorized admins can access", authorized_roles: authorized_roles
    end
  end
end
