# frozen_string_literal: true
require 'spec_helper'

describe ExternalAuthorsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { FactoryGirl.create(:user) }
  let(:invitation) { FactoryGirl.create(:invitation, external_author: external_author) }
  let(:external_author) { FactoryGirl.create(:external_author) }

  before(:each) do
    fake_login_known_user(user)
  end

  describe "GET #get_external_author_from_invitation" do
    context "with invalid invitation token" do
      it "redirects with an error" do
        get :get_external_author_from_invitation, invitation_token: "None existent"
        it_redirects_to_with_error(root_path, "You need an invitation to do that.")
      end
    end

    context "with valid invitation token" do
      xit "assigns invitation" do
        # ActionView::MissingTemplate:
        # Missing template external_authors/get_external_author_from_invitation, application/get_external_author_from_invitation with {:locale=>[:en], :formats=>[:html], :handlers=>[:erb, :builder]}. Searched in:
        get :get_external_author_from_invitation, invitation_token: invitation.token
        expect(assigns(:invitation)).to eq(invitation)
        assert_equal response.status, 200
      end
    end
   
    context "without works to claim" do
      it "redirects with an error" do
        no_story_invitation = FactoryGirl.create(:invitation)
        get :get_external_author_from_invitation, invitation_token: no_story_invitation.token
        it_redirects_to_with_error(signup_path(no_story_invitation.token), "There are no stories to claim on this invitation. Did you want to sign up instead?")
      end
    end
  end

  describe "GET #complete_claim" do 
    it "redirects with a success message" do
      get :complete_claim, invitation_token: invitation.token
      it_redirects_to_with_notice(user_external_authors_path(user), "We have added the stories imported under #{external_author.email} to your account.")
    end
  end 

  describe "GET #update" do
    it "redirects with an error if the user does not have permission" do
      wrong_external_author = FactoryGirl.create(:external_author)
      someone_elses_invitation = FactoryGirl.create(:invitation, external_author: wrong_external_author)
      get :update, invitation_token: someone_elses_invitation.token, id: external_author.id
      it_redirects_to_with_error(root_path, "You don't have permission to do that.")
    end

    context "When the user has permission" do
      context "when doing nothing with imported works" do
        it "redirects with a success message" do
          get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "nothing"
          it_redirects_to_with_notice(root_path, "Okay, we'll leave things the way they are! You can use the email link any time if you change your mind.")
        end
      end

      context "when orphaning imported works" do
        it "redirects with a success message" do
          get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "orphan"
          it_redirects_to_with_notice(root_path, "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved.")
        end
 
        context "when updating preferences" do
          xit "renders edit template with a success message for orphaning and an error for preferences" do
            allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_return(false)
            get :update, invitation_token: invitation.token, id: external_author.id, imported_stories: "orphan"
            allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_call_original
            expect(response).to render_template :edit
            expect(flash[:notice]).to eq "Your imported stories have been orphaned. Thank you for leaving them in the archive! "
            expect(flash[:error]).to eq "There were problems saving your preferences."
          end
        end
      end
    end
  end

  describe "GET #edit" do
    it "assigns external_author" do
      user.save
      get :edit, id: external_author.id, user_id: user.login
      expect(assigns(:external_author)).to eq(external_author)
    end
  end

  describe "GET #index" do
    it "redirects and gives a notice when not logged in" do
      fake_logout
      get :index
      it_redirects_to_with_notice(root_path, "You can't see that information.")
    end

    it "assigns @external_authors" do
      external_author.claim!(user)     
      get :index, user_id: user.login
      expect(assigns(:external_authors)).to eq([external_author])
    end

    it "redirects when you are logged in" do
      get :index
      it_redirects_to(user_external_authors_path(user))
    end

    it "archivist are special" do
      allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)
      get :index
      allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
      expect(assigns(:external_authors)).to eq([])
    end
  end
end
