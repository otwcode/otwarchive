require "spec_helper"

describe ChallengeRequestsController do 
  include LoginMacros
  include RedirectExpectationHelper

  describe "index" do
    context "when there are anonymous prompts" do
      render_views
      it "does not throw a 500 error if sorting by prompter with an anonymous prompt" do
        signup = create(:prompt_meme_signup)  
        signup.requests.create(anonymous: true)
        get :index, params: { collection_id: signup.collection.name, sort_column: "prompter" }
        expect(response.status).not_to eq(500)
      end
    end
  end
end
