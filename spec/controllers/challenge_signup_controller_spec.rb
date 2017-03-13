# frozen_string_literal: true
require 'spec_helper'

RSpec.describe ChallengeSignupsController, type: :controller do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:signup) { create(:challenge_signup, collection_id: create(:collection, challenge: create(:gift_exchange, :closed))) }
  let(:collection) { signup.collection}
  let(:challenge) { collection.challenge }
  let(:collection_owner) { User.find(collection.all_owners.first.user_id) }

  let(:open_signup) { create(:challenge_signup, collection_id: create(:collection, challenge: create(:gift_exchange, :open))) }
  let(:open_collection) { open_signup.collection }
  let(:open_challenge) { open_collection.challenge }

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

  describe "summary" do
    it "writes a file for big challenges" do
      expected_filename = ChallengeSignup.summary_file(collection)
      File.delete(expected_filename) if File.file?(expected_filename)
      ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT = 2
      ArchiveConfig.MAX_SIGNUPS_FOR_LIVE_SUMMARY = 0
      get :summary, id: challenge, collection_id: collection.name
      binding.pry
      expect(File.file?(expected_filename)).to be true
    end
  end
end
