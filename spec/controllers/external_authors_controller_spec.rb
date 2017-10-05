# frozen_string_literal: true
require 'spec_helper'

describe ExternalAuthorsController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }
  let(:invitation) { create(:invitation, external_author: external_author) }
  let(:external_author) { create(:external_author) }

  before(:each) do
    fake_login_known_user(user)
  end

  describe "GET #claim" do
    context "with invalid invitation token" do
      it "redirects with an error" do
        get :claim, params: { invitation_token: "None existent" }
        it_redirects_to_with_error(root_path, "You need an invitation to do that.")
      end
    end

    context "with valid invitation token" do
      it "assigns invitation" do
        get :claim, params: { invitation_token: invitation.token }
        expect(assigns(:invitation)).to eq(invitation)
        assert_equal response.status, 200
      end
    end

    context "without works to claim" do
      it "redirects with an error" do
        no_story_invitation = create(:invitation)
        get :claim, params: { invitation_token: no_story_invitation.token }
        it_redirects_to_with_error(signup_path(no_story_invitation.token), "There are no stories to claim on this invitation. Did you want to sign up instead?")
      end
    end
  end

  describe "GET #complete_claim" do
    it "redirects with a success message" do
      expect(external_author.user).to be_nil
      expect(external_author.claimed?).to be_falsy

      expect(invitation.invitee).to be_nil
      expect(invitation.redeemed_at).to be_nil

      get :complete_claim, params: { invitation_token: invitation.token }
      it_redirects_to_with_notice(user_external_authors_path(user), "We have added the stories imported under #{external_author.email} to your account.")

      external_author.reload
      expect(external_author.user).to eq(user)
      expect(external_author.claimed?).to be_truthy

      invitation.reload
      expect(invitation.invitee).to eq(user)
      expect(invitation.redeemed_at).not_to be_nil
    end
  end

  describe "PUT #update" do
    it "redirects with an error if the user does not have permission" do
      wrong_external_author = create(:external_author)
      someone_elses_invitation = create(:invitation, external_author: wrong_external_author)
      put :update, params: { invitation_token: someone_elses_invitation.token, id: external_author.id }
      it_redirects_to_with_error(root_path, "You don't have permission to do that.")
    end

    context "when the logged in user is the external author" do
      before(:each) do
        external_author.claim!(user)
      end

      context "when doing nothing with imported works" do
        it "redirects with a success message" do
          put :update, params: { user_id: user.login, id: external_author.id, imported_stories: "nothing" }
          it_redirects_to_with_notice(root_path, "Okay, we'll leave things the way they are! You can use the email link any time if you change your mind.")
        end
      end

      context "when orphaning imported works" do
        it "redirects with a success message" do
          put :update, params: { user_id: user.login, id: external_author.id, imported_stories: "orphan" }
          it_redirects_to_with_notice(user_external_authors_path(user), "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved.")
        end
      end

      context "when deleting imported works" do
        it "redirects with a success message" do
          put :update, params: { user_id: user.login, id: external_author.id, imported_stories: "delete" }
          it_redirects_to_with_notice(user_external_authors_path(user), "Your imported stories have been deleted. Your preferences have been saved.")
        end
      end
    end

    context "when the user has permission through an invitation" do
      context "when doing nothing with imported works" do
        it "redirects with a success message" do
          parameters =  {
            invitation_token: invitation.token,
            id: external_author.id,
            imported_stories: "nothing"
          }

          put :update, params: parameters
          it_redirects_to_with_notice(root_path, "Okay, we'll leave things the way they are! You can use the email link any time if you change your mind.")
          invitation.reload
          expect(invitation.invitee).to be_nil
          expect(invitation.redeemed_at).to be_nil
        end
      end

      context "when orphaning imported works" do
        it "redirects with a success message" do
          parameters = {
            invitation_token: invitation.token,
            id: external_author.id,
            imported_stories: "orphan"
          }

          put :update, params: parameters
          it_redirects_to_with_notice(root_path, "Your imported stories have been orphaned. Thank you for leaving them in the archive! Your preferences have been saved.")
          invitation.reload
          expect(invitation.invitee).to be_nil
          expect(invitation.redeemed_at).not_to be_nil
        end

        context "when updating preferences" do
          xit "renders edit template with a success message for orphaning and an error for preferences" do
            parameters = {
              invitation_token: invitation.token,
              id: external_author.id,
              imported_stories: "orphan",
              do_not_email: true
            }

            allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_return(false)
            put :update, params: parameters
            allow_any_instance_of(ExternalAuthor).to receive(:update_attributes).and_call_original
            expect(response).to render_template :edit
            expect(flash[:notice]).to eq "Your imported stories have been orphaned. Thank you for leaving them in the archive! "
            expect(flash[:error]).to eq "There were problems saving your preferences."
          end
        end
      end

      context "when deleting imported works" do
        it "redirects with a success message" do
          parameters = {
            invitation_token: invitation.token,
            id: external_author.id,
            imported_stories: "delete"
          }

          put :update, params: parameters
          it_redirects_to_with_notice(root_path, "Your imported stories have been deleted. Your preferences have been saved.")
          invitation.reload
          expect(invitation.invitee).to be_nil
          expect(invitation.redeemed_at).not_to be_nil
        end
      end
    end
  end

  describe "GET #edit" do
    it "assigns external_author" do
      get :edit, params: { id: external_author.id, user_id: user.login }
      expect(assigns(:external_author)).to eq(external_author)
    end
  end

  describe "GET #index" do
    context "when logged out" do
      before(:each) do
        fake_logout
      end

      it "redirects with notice" do
        get :index
        it_redirects_to_with_notice(root_path, "You can't see that information.")
      end
    end

    context "when logged in as user" do
      context "without archivist permissions" do
        it "assigns external_authors" do
          external_author.claim!(user)
          get :index, params: { user_id: user.login }
          expect(assigns(:external_authors)).to eq([external_author])
        end

        it "redirects" do
          get :index
          it_redirects_to(user_external_authors_path(user))
        end
      end
    end

    context "with archivist permissions" do
      before(:each) do
        allow_any_instance_of(User).to receive(:is_archivist?).and_return(true)
      end

      after(:each) do
        allow_any_instance_of(User).to receive(:is_archivist?).and_call_original
      end

      it "assigns external_authors and renders index" do
        get :index
        expect(assigns(:external_authors)).to eq([])
        expect(response).to render_template :index
      end
    end
  end
end
