# frozen_string_literal: true
require 'spec_helper'

describe ExternalAuthorsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { FactoryGirl.create(:user) }

  describe "GET #get_external_author_from_invitation" do
    it "needs a valid invitaiton" do
      get :get_external_author_from_invitation, invitation_token: "None existent"
      it_redirects_to_with_error(root_path, "You need an invitation to do that.")
    end
   
    it "needs to have a story assocated with the invitation" do
      invitation = FactoryGirl.create(:invitation)
      get :get_external_author_from_invitation, invitation_token: invitation.token
      it_redirects_to_with_error(signup_path(invitation.token), "There are no stories to claim on this invitation. Did you want to sign up instead?")
    end
  end

  describe "GET #complete_claim" do 
    it "should give the user the works" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      invitation = FactoryGirl.create(:invitation, external_author: external_author)
      get :complete_claim, invitation_token: invitation.token
      it_redirects_to_with_notice(user_external_authors_path(user), "We have added the stories imported under #{external_author.email} to your account.")
    end
  end 

  describe "GET #update" do
    it "needs to be done by the right user" do
      external_author = FactoryGirl.create(:external_author)
      wrong_external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      invitation = FactoryGirl.create(:invitation, external_author: wrong_external_author)
      get :update, invitation_token: invitation.token, id: external_author.id
      it_redirects_to_with_error(root_path, "You don't have permission to do that.")
    end

    it "can do nothing" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      invitation = FactoryGirl.create(:invitation, external_author: external_author)
      get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "nothing"
      it_redirects_to_with_notice(root_path, "Okay, we'll leave things the way they are! You can use the email link any time if you change your mind.")
    end

    it "can be orphaned" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      invitation = FactoryGirl.create(:invitation, external_author: external_author)
      get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "orphan"
      it_redirects_to_with_notice(root_path, "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved.")
    end

    xit "errors if the preferences can't be saved" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      invitation = FactoryGirl.create(:invitation, external_author: external_author)
      allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_return(false)
      get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "orphan"
      allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_call_original
      it_redirects_to_with_notice(root_path, "Your imported stories have been orphaned. Thank you for leaving them in the archive! There were problems saving your preferences.")
    end
  end

  describe "GET #edit" do
    it "assigns external_author" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      user.save
      fake_login_known_user(user)
      get :edit, id: external_author.id, user_id: user.login
      expect(assigns(:external_author)).to eq(external_author)
    end
  end

  describe "GET #index" do
    it "redirects and gives a notice when not logged in" do
      get :index
      it_redirects_to_with_notice(root_path, "You can't see that information.")
    end

    it "assigns @external_authors" do
      external_author = FactoryGirl.create(:external_author)
      user = FactoryGirl.create(:user)
      external_author.claim!(user)     
      fake_login_known_user(user)
      get :index, user_id: user.login
      expect(assigns(:external_authors)).to eq([external_author])
    end

    it "redirects when you are logged in" do
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      get :index
      it_redirects_to(user_external_authors_path(user))
    end

    it "archivist are special" do
      user = FactoryGirl.create(:user)
      fake_login_known_user(user)
      allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)
      get :index
      allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
      expect(assigns(:external_authors)).to eq([])
    end
  end
end
