require "spec_helper"

describe PromptsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:collection) { create(:collection) }
  let(:open_signup) do
    signups = create(:challenge_signup)
    signups.collection.challenge.signup_open = true
    signups.collection.challenge.save
    signups
  end
  let(:signup) { create(:challenge_signup) }

  let(:user) { create(:user) }
  before do
    fake_login_known_user(user)
  end

  describe "no_challenge" do
    it "should show an error and redirect" do
      get :show, collection_id: collection.name
      it_redirects_to_with_error(collection_path(collection), "What challenge did you want to sign up for?")
    end
  end

  describe "no_signup" do
    it "should show an error and redirect" do
      post :create, collection_id: signup.collection.name
      it_redirects_to_with_error(collection_signups_path(signup.collection) + "/new",\
                                 "Please submit a basic sign-up with the required fields first.")
    end
  end

  describe "signups_closed" do
    let(:user) { Pseud.find(ChallengeSignup.in_collection(signup.collection).first.pseud_id).user }
    it "should show an error and redirect" do
      post :create, collection_id: signup.collection.name
      it_redirects_to_with_error(signup.collection, "Signup is currently closed: please contact a moderator for help.")
    end
  end

  describe "not_signup_owner" do
    it "should show an error and redirect" do
      prompt = signup.collection.prompts.first
      post :edit, id: prompt.id, collection_id: signup.collection.name
      it_redirects_to_with_error(signup.collection, "You can't edit someone else's sign-up!")
    end
  end

  describe "new" do
    context "when prompt_type is offer" do
      let(:user) { Pseud.find(ChallengeSignup.in_collection(open_signup.collection).first.pseud_id).user }
      it "should have no errors" do
        post :new, collection_id: open_signup.collection.name, prompt_type: "offer"
        expect(response).to have_http_status(200)
        expect(flash[:error]).blank?
        expect(assigns(:index)).to eq(open_signup.offers.count)
      end
    end
  end

  describe "create" do
    let(:user) { Pseud.find(ChallengeSignup.in_collection(open_signup.collection).first.pseud_id).user }
    it "should have no errors and redirect to the edit page" do
      post :create, collection_id: open_signup.collection.name, prompt_type: "offer", prompt: {}
      it_redirects_to "#{collection_signups_path(open_signup.collection)}/"\
                      "#{open_signup.collection.prompts.first.challenge_signup_id}/edit"
      expect(flash[:error]).blank?
      expect(flash[:notice]).blank?
    end
  end

  describe "update" do
    context "when prompt is valid" do
      let(:user) { Pseud.find(ChallengeSignup.in_collection(open_signup.collection).first.pseud_id).user }
      it "should save the prompt and redirect with a success message" do
        put :update, collection_id: open_signup.collection.name, prompt_type: "offer",\
                     prompt: { description: "This is a description" }, id: open_signup.collection.prompts.first.id
        it_redirects_to_with_notice("#{collection_signups_path(open_signup.collection)}/#{open_signup.id}",
                                    "Prompt was successfully updated.")
        new_prompt = open_signup.collection.prompts.first
        expect(new_prompt.description).to eq("<p>This is a description</p>")
      end
    end
  end

  describe "destroy" do
    let(:user) { Pseud.find(ChallengeSignup.in_collection(signup.collection).first.pseud_id).user }
    it "redirects with an error when sign-ups are closed" do
      prompt = signup.collection.prompts.first
      delete :destroy, collection_id: signup.collection.name, id: prompt.id
      it_redirects_to_with_error("#{collection_signups_path(signup.collection)}/#{signup.id}",
                                 "You cannot delete a prompt after sign-ups are closed."\
                                  " Please contact a moderator for help.")
    end

    context "where current_user is signup owner" do
      let(:user) { Pseud.find(ChallengeSignup.in_collection(open_signup.collection).first.pseud_id).user }
      it "redirects with an error when it would make a sign-up invalid" do
        delete :destroy, collection_id: open_signup.collection.name, id: open_signup.collection.prompts.first.id
        it_redirects_to_with_error("#{collection_signups_path(open_signup.collection)}/#{open_signup.id}",
                                   "That would make your sign-up invalid, sorry! Please edit instead.")
      end

      it "deletes the prompt and redirects with a success message" do
        prompt = open_signup.offers.build(pseud_id: ChallengeSignup.in_collection(open_signup.collection).first.pseud_id,\
                                          collection_id: open_signup.collection.id)
        prompt.save
        delete :destroy, collection_id: open_signup.collection.name, id: prompt.id
        it_redirects_to_with_notice("#{collection_signups_path(open_signup.collection)}/#{open_signup.id}",
                                    "Prompt was deleted.")
      end
    end
  end

  describe "edit" do
    context "no prompt" do
      it "should show an error and redirect" do
        post :edit, collection_id: signup.collection.name
        it_redirects_to_with_error(collection_path(signup.collection), "What prompt did you want to work on?")
      end
    end
  end
end
