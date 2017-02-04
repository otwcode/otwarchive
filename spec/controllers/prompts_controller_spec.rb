require "spec_helper"

describe PromptsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:collection) { create(:collection) }

  before do
    fake_login
  end

  describe "no_challenge" do
    it "should show an error and redirect" do
      get :show, collection_id: collection.name
      it_redirects_to collection_path(collection)
      expect(flash[:error]).to eq "What challenge did you want to sign up for?"
    end
  end

  describe "no_signup" do
    it "should show an error and redirect" do
      signups = create(:challenge_signup)
      post :create, collection_id: signups.collection.name
      it_redirects_to collection_signups_path(signups.collection) + "/new"
      expect(flash[:error]).to eq "Please submit a basic sign-up with the required fields first."
    end
  end

  describe "signups_closed" do
    it "should show an error and redirect" do
      signups = create(:challenge_signup)
      # Login as the signup owner
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      post :create, collection_id: signups.collection.name
      it_redirects_to collection_path(signups.collection)
      expect(flash[:error]).to eq "Signup is currently closed: please contact a moderator for help."
    end
  end

  describe "not_signup_owner" do
    it "should show an error and redirect" do
      signups = create(:challenge_signup)
      prompt = signups.collection.prompts.first
      post :edit, id: prompt.id, collection_id: signups.collection.name
      it_redirects_to collection_path(signups.collection)
      expect(flash[:error]).to eq "You can't edit someone else's sign-up!"
    end
  end

  describe "new_prompt_offer" do
    it "should have no errors and redirect" do
      signups = create(:challenge_signup)
      signups.collection.challenge.signup_open = true
      signups.collection.challenge.save
      # Login as the signup owner
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      post :new, collection_id: signups.collection.name, prompt_type: "offer"
      expect(response).to have_http_status(200)
      expect(flash[:error]).blank?
    end
  end

  describe "create_prompt_offer" do
    it "should have no errors and redirect" do
      signups = create(:challenge_signup)
      prompt = signups.collection.prompts.first
      signups.collection.challenge.signup_open = true
      signups.collection.challenge.save
      # Login as the signup owner
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      post :create, collection_id: signups.collection.name, prompt_type: "offer", prompt: {}
      it_redirects_to "#{collection_signups_path(signups.collection)}/#{prompt.challenge_signup_id}/edit"
      expect(flash[:notice]).blank?
      expect(flash[:error]).blank?
    end
  end

  describe "update_prompt" do
    it "should have no errors and redirect" do
      signups = create(:challenge_signup)
      prompt = signups.collection.prompts.first
      signups.collection.challenge.signup_open = true
      signups.collection.challenge.save
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      put :update, collection_id: signups.collection.name, prompt_type: "offer",\
                   prompt: { description: "This is a description" }, id: prompt.id
      expect(flash[:notice]).to eq "Prompt was successfully updated."
      expect(flash[:error]).blank?
      it_redirects_to "#{collection_signups_path(signups.collection)}/#{signups.id}"
      new_prompt = signups.collection.prompts.first
      expect(new_prompt.description).to eq("<p>This is a description</p>")
    end
  end

  describe "destroy" do
    it "can not delete a prompt after sign-ups are closed." do
      signups = create(:challenge_signup)
      prompt = signups.collection.prompts.first
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      delete :destroy, collection_id: signups.collection.name, id: prompt.id
      expect(flash[:error]).to eq "You cannot delete a prompt after sign-ups are closed."\
                                  " Please contact a moderator for help."
      it_redirects_to "#{collection_signups_path(signups.collection)}/#{signups.id}"
    end

    it "can not delete a prompt if it would make it invalid" do
      signups = create(:challenge_signup)
      prompt = signups.collection.prompts.first
      signups.collection.challenge.signup_open = true
      signups.collection.challenge.save
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      delete :destroy, collection_id: signups.collection.name, id: prompt.id
      expect(flash[:error]).to eq "That would make your sign-up invalid, sorry! Please edit instead."
      it_redirects_to "#{collection_signups_path(signups.collection)}/#{signups.id}"
    end

    it "we can delete a new prompt." do
      signups = create(:challenge_signup)
      signups.collection.challenge.signup_open = true
      signups.collection.challenge.save
      # Login as the signup owner
      fake_login_known_user(Pseud.find(ChallengeSignup.in_collection(signups.collection).first.pseud_id).user)
      prompt = signups.offers.build(pseud_id: ChallengeSignup.in_collection(signups.collection).first.pseud_id,\
                                    collection_id: signups.collection.id)
      prompt.save
      delete :destroy, collection_id: signups.collection.name, id: prompt.id
      expect(flash[:error]).blank?
      expect(flash[:notice]).to eq "Prompt was deleted."
      it_redirects_to "#{collection_signups_path(signups.collection)}/#{signups.id}"
    end
  end

  describe "no_prompt" do
    it "should show an error and redirect" do
      signups = create(:challenge_signup)
      post :edit, collection_id: signups.collection.name
      it_redirects_to collection_path(signups.collection)
      expect(flash[:error]).to eq "What prompt did you want to work on?"
    end
  end
end
