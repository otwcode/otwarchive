# frozen_string_literal: true
require 'spec_helper'

describe ChallengeClaimsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:signup) { create(:challenge_signup) }
  let(:collection) { signup.collection }
  let(:claim) { create(:challenge_claim, collection: collection) }

  describe 'index' do
    it 'assigns claims and gives a notice if the collection is closed and the user is not the maintainer' do
      fake_login_known_user(user)
      allow_any_instance_of(Collection).to receive(:closed?) { true }
      get :index, params: { id: claim.id, collection_id: collection.name, for_user: true }
      expect(flash[:notice]).to include("This challenge is currently closed to new posts.")
      expect(assigns(:claims))
    end

    it 'will not allow you to see someone elses claims' do
      second_user = create(:user)
      fake_login_known_user(user)
      get :index, params: { user_id: second_user.login }
      it_redirects_to_with_error(root_path, \
                                 "You aren't allowed to see that user's claims.")
    end

    context "for a prompt meme" do
      let(:signup) { create(:prompt_meme_signup) }

      it "will not allow a logged in user to see everyone's claims" do
        fake_login_known_user(user)

        get :index, params: { collection_id: collection.name }

        it_redirects_to_with_error(collection, "Sorry, you're not allowed to do that.")
      end

      it "will allow a maintainer to see everyone's claims" do
        collection.collection_participants.create(pseud: user.pseuds.first, participant_role: "Moderator")
        fake_login_known_user(user)

        get :index, params: { collection_id: collection.name }

        expect(flash[:error]).to be_blank
        expect(assigns(:claims))
      end
    end
  end

  describe 'show' do
    it 'redirects logged in user to the prompt' do
      request_prompt = create(:prompt, collection_id: collection.id, challenge_signup_id: signup.id)
      claim_with_prompt = create(:challenge_claim, collection: collection, request_prompt_id: request_prompt.id)
      fake_login_known_user(user)
      get :show, params: { id: claim_with_prompt.id, collection_id: collection.name }
      it_redirects_to(collection_prompt_path(collection, claim_with_prompt.request_prompt))
    end

    xit 'needs a collection' do
      fake_login_known_user(user)
      get :show
      it_redirects_to_with_error(root_path, \
                                 "What challenge did you want to work with?")
    end
  end

  describe 'create' do
    it 'sets a notice and redirects' do
      fake_login_known_user(@user)
      post :create, params: { collection_id: collection.name, challenge_claim: {collection_id: collection.id} }
      it_redirects_to_with_notice(collection_claims_path(collection, for_user: true), \
                                  "New claim made.")
    end

    it 'on an exception gives an error and redirects' do
      fake_login_known_user(@user)
      allow_any_instance_of(ChallengeClaim).to receive(:save) { false }
      post :create, params: { collection_id: collection.name, challenge_claim: {collection_id: collection.id} }
      it_redirects_to_with_error(collection_claims_path(collection, for_user: true), \
                                 "We couldn't save the new claim.")
    end
  end

  describe "destroy" do
    context "for a prompt meme" do
      let(:signup) { create(:prompt_meme_signup) }

      context "when a user deletes their own claim" do
        before do
          claim.update!(claiming_user: user)
        end

        it "redirects them to their claims in collection page" do
          fake_login_known_user(user)

          delete :destroy, params: { id: claim.id, collection_id: collection.name }

          it_redirects_to_with_notice(collection_claims_path(collection, for_user: true),
                                      "Your claim was deleted.")
        end
      end

      context "when a maintainer deletes someone else's claim" do
        before do
          collection.collection_participants.create(pseud: user.pseuds.first, participant_role: "Moderator")
        end

        it "redirects them to the collection claims page" do
          fake_login_known_user(user)

          delete :destroy, params: { id: claim.id, collection_id: collection.name }

          it_redirects_to_with_notice(collection_claims_path(collection),
                                      "The claim was deleted.")
        end
      end
    end

    context "when an exception occurs" do
      before do
        collection.collection_participants.create(pseud: user.pseuds.first, participant_role: "Moderator")
        allow_any_instance_of(ChallengeClaim).to receive(:destroy) { raise ActiveRecord::RecordNotDestroyed }
      end

      it "gives an error and redirects" do
        fake_login_known_user(user)

        delete :destroy, params: { id: claim.id, collection_id: collection.name }

        it_redirects_to_with_error(collection_claims_path(collection), \
                                   "We couldn't delete that right now, sorry! Please try again later.")
      end
    end
  end
end
