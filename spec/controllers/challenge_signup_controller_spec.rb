# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ChallengeSignupsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:signup) do
    challenge = create(:gift_exchange, :closed)
    collection = create(:collection, challenge: challenge)
    signup = build(:challenge_signup, collection_id: collection)
    signup.collection = collection
    signup.save
    signup
  end
  let(:collection) { signup.collection }
  let(:challenge) { signup.collection.challenge }
  let(:collection_owner) { User.find(collection.all_owners.first.user_id) }
  let(:signup_owner) { Pseud.find(signup.pseud_id).user }

  let(:open_signup) do
    challenge = create(:gift_exchange, :open)
    collection = create(:collection, challenge: challenge)
    signup = build(:challenge_signup, collection_id: collection)
    signup.collection = collection
    signup.save
    signup
  end
  let(:open_collection) { open_signup.collection }
  let(:open_challenge) { open_signup.collection.challenge }
  let(:open_signup_owner) { Pseud.find(open_signup.pseud_id).user }

  describe "new" do
    it "ensures signups are open" do
      fake_login_known_user(user)
      get :new, collection_id: collection.name, pseud: user.pseuds.first
      it_redirects_to_with_error(collection_path(collection), \
                                 "Sign-up is currently closed: please contact a moderator for help.")
    end
  end

  describe "show" do
    xit "checks that there is a challenge" do
      fake_login_known_user(collection_owner)
      get :show, id: 999_999, collection_id: collection.name
      it_redirects_to_with_error(collection_path(collection), \
                                 "What sign-up did you want to work on?")
    end

    it "checks ownership" do
      fake_login_known_user(user)
      get :show, id: signup, collection_id: collection.name
      it_redirects_to_with_error(collection_path(collection), \
                                 "Sorry, you're not allowed to do that.")
    end
  end

  describe "update" do
    it "checks for the right owner" do
      fake_login_known_user(user)
      get :edit, id: signup, collection_id: collection.name
      it_redirects_to_with_error(collection_path(collection), \
                                 "You can't edit someone else's sign-up!")
    end
  end

  describe "index" do
    it "checks for the right owner" do
      fake_login_known_user(user)
      get :index, id: challenge, collection_id: collection.name, user_id: collection_owner
      it_redirects_to_with_error(root_path, \
                                 "You aren't allowed to see that user's sign-ups.")
    end
  end

  describe "destroy" do
    context "signups are open" do
      it "checks that signups are open" do
        fake_login_known_user(open_signup_owner)
        delete :destroy, id: open_signup, collection_id: open_collection.name
        it_redirects_to_with_notice(collection_path(open_collection), \
                                    "Challenge sign-up was deleted.")
      end
    end
    context "signups are closed" do
      it "checks that signups are open" do
        fake_login_known_user(signup_owner)
        delete :destroy, id: signup, collection_id: collection.name
        it_redirects_to_with_error(collection_path(collection), \
                                   "You cannot delete your sign-up after sign-ups are closed. Please contact a moderator for help.")
      end
    end
  end

  describe "update" do
    context "signups are open" do
      it "renders edit if update_attributes fails" do
        fake_login_known_user(open_signup_owner)
        allow_any_instance_of(ChallengeSignup).to receive(:update).and_return(false)
        put :update, challenge_signup: { pseud_id: open_signup_owner.pseuds.first.id }, id: open_signup, collection_id: open_collection.name
        allow_any_instance_of(ChallengeSignup).to receive(:update).and_call_original
        expect(response).to render_template('edit')
      end

      it "checks ownership of the signup" do
        fake_login_known_user(user)
        put :update, challenge_signup: { pseud_id: signup_owner.pseuds.first.id }, id: signup, collection_id: collection.name
        it_redirects_to_with_error(collection, \
                                   "You can't edit someone else's sign-up!")
      end
    end

    context "signups are closed" do
      it "does not allow edits when signups are closed" do
        fake_login_known_user(signup_owner)
        put :update, challenge_signup: { pseud_id: signup_owner.pseuds.first.id }, id: signup, collection_id: collection.name
        it_redirects_to_with_error(collection, \
                                   "Sign-up is currently closed: please contact a moderator for help.")
      end
    end
  end

  describe "summary" do
    it "writes a file for big challenges" do
      expected_filename = ChallengeSignup.summary_file(collection)
      File.delete(expected_filename) if File.file?(expected_filename)
      ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT = 2
      ArchiveConfig.MAX_SIGNUPS_FOR_LIVE_SUMMARY = 0
      get :summary, id: challenge, collection_id: collection.name
      expect(File.file?(expected_filename)).to be true
    end
  end
end
