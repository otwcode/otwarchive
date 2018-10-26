require 'spec_helper'

describe ChallengeSignupsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
 
  let(:closed_challenge) { create(:gift_exchange, :closed) }
  let(:closed_collection) { create(:collection, challenge: closed_challenge) }
  let(:closed_signup) { create(:gift_exchange_signup, collection_id: closed_collection.id) }
  let(:closed_collection_owner) { User.find(closed_collection.all_owners.first.user_id) }
  let(:closed_signup_owner) { Pseud.find(closed_signup.pseud_id).user }

  let(:open_challenge) { create(:gift_exchange, :open) }
  let(:open_collection) { create(:collection, challenge: open_challenge) }
  let(:open_signup) { create(:gift_exchange_signup, collection_id: open_collection.id) }
  let(:open_collection_owner) { User.find(open_collection.all_owners.first.user_id) }
  let(:open_signup_owner) { Pseud.find(open_signup.pseud_id).user }

  describe "new" do
    it "redirects and errors if sign-up is not open" do
      fake_login_known_user(user)
      get :new, params: { collection_id: closed_collection.name, pseud: user.pseuds.first }
      it_redirects_to_with_error(collection_path(closed_collection),
                                 "Sign-up is currently closed: please contact a moderator for help.")
    end
  end

  describe "show" do
    xit "redirects and errors if there is no challenge associated with the collection" do
      fake_login_known_user(closed_collection_owner)
      get :show, params: { id: 999_999, collection_id: closed_collection.name }
      it_redirects_to_with_error(collection_path(closed_collection),
                                 "What sign-up did you want to work on?")
    end

    it "redirects and errors if the user does not own the sign-up" do
      fake_login_known_user(user)
      get :show, params: { id: closed_signup, collection_id: closed_collection.name }
      it_redirects_to_with_error(collection_path(closed_collection),
                                 "Sorry, you're not allowed to do that.")
    end
  end

  describe "index" do
    it "redirects and errors if the current user is not allowed to see the specified user's sign-ups" do
      fake_login_known_user(user)
      get :index, params: { id: closed_challenge, collection_id: closed_collection.name, user_id: closed_collection_owner }
      it_redirects_to_with_error(root_path,
                                 "You aren't allowed to see that user's sign-ups.")
    end
  end

  describe "destroy" do
    context "when sign-ups are open" do
      it "deletes the sign-up and redirects with notice" do
        fake_login_known_user(open_signup_owner)
        delete :destroy, params: { id: open_signup, collection_id: open_collection.name }
        it_redirects_to_with_notice(collection_path(open_collection),
                                    "Challenge sign-up was deleted.")
      end
    end
    context "when sign-ups are closed" do
      it "redirects and errors" do
        fake_login_known_user(closed_signup_owner)
        delete :destroy, params: { id: closed_signup, collection_id: closed_collection.name }
        it_redirects_to_with_error(collection_path(closed_collection),
                                   "You cannot delete your sign-up after sign-ups are closed. Please contact a moderator for help.")
      end
    end
  end

  describe "update" do
    context "when sign-ups are open" do
      let(:params) do
        { 
          challenge_signup: { pseud_id: open_signup_owner.pseuds.first.id },
          id: open_signup,
          collection_id: open_collection.name
        }
      end

      it "renders edit if update_attributes fails" do
        fake_login_known_user(open_signup_owner)
        allow_any_instance_of(ChallengeSignup).to receive(:update_attributes).and_return(false)
        put :update, params: params
        allow_any_instance_of(ChallengeSignup).to receive(:update_attributes).and_call_original
        expect(response).to render_template :edit
      end

      it "redirects and errors if the current user can't edit the sign-up" do
        fake_login_known_user(user)
        put :update, params: params
        it_redirects_to_with_error(open_collection,
                                   "You can't edit someone else's sign-up!")
      end
    end

    context "when signups are closed" do
      let(:params) do
        { 
          challenge_signup: { pseud_id: closed_signup_owner.pseuds.first.id },
          id: closed_signup,
          collection_id: closed_collection.name
        }
      end

      it "redirects and errors without updating the sign-up" do
        fake_login_known_user(closed_signup_owner)
        put :update, params: params
        it_redirects_to_with_error(closed_collection,
                                   "Sign-up is currently closed: please contact a moderator for help.")
      end

      it "redirects and errors if the current user can't edit the sign-up" do
        fake_login_known_user(user)
        put :update, params: params
        it_redirects_to_with_error(closed_collection,
                                   "You can't edit someone else's sign-up!")
      end
    end
  end

  describe "gift_exchange_to_csv" do
    let(:collection) { create(:collection, challenge: create(:gift_exchange)) }
    let(:signup) { create(:gift_exchange_signup, collection_id: collection.id) }

    before do
      signup_offer = signup.offers.first
      signup_offer.tag_set = create(:tag_set)
      signup_offer.save
      
      signup_request = signup.requests.first
      signup_request.tag_set = create(:tag_set)
      signup_request.save
    end

    it "generates a CSV with all the challenge information" do
      controller.instance_variable_set(:@challenge, collection.challenge)
      controller.instance_variable_set(:@collection, collection)
      expect(controller.send(:gift_exchange_to_csv))
        .to eq([["Pseud", "Email", "Sign-up URL", "Request 1 Tags", "Request 1 Description", "Offer 1 Tags", "Offer 1 Description"],
                [signup.pseud.name, signup.pseud.user.email, collection_signup_url(collection, signup),
                 signup.requests.first.tag_set.tags.first.name, "", signup.offers.first.tag_set.tags.first.name, ""]])
    end
  end

  describe "prompt_meme_to_csv" do
    let(:tag_set) { create(:tag_set) }
    let(:collection) { create(:collection, challenge: create(:prompt_meme)) }
    let(:signup) { create(:prompt_meme_signup, collection_id: collection.id) }

    before do
      prompt = signup.prompts.first
      prompt.tag_set = create(:tag_set)
      prompt.save
    end

    it "generates a CSV with all the challenge information" do
      controller.instance_variable_set(:@challenge, collection.challenge)
      controller.instance_variable_set(:@collection, collection)
      expect(controller.send(:prompt_meme_to_csv))
        .to eq([["Pseud", "Email", "Sign-up URL", "Tags", "Description"],
                [signup.pseud.name, signup.pseud.user.email, collection_signup_url(collection, signup),
                 signup.requests.first.tag_set.tags.first.name, ""]])
    end
  end
end
