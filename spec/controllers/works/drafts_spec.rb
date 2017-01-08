# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros

  let(:drafts_user_pseud) { create(:pseud, name: "Visiting User Pseud") }
  let(:drafts_user) {
    user = create(:user)
    user.pseuds << drafts_user_pseud
    user
  }
  let!(:default_pseud_work) {
    create(:work, authors: [drafts_user.default_pseud], posted: false, title: "Default pseud work")
  }
  let!(:other_pseud_work) {
    create(:work, authors: [drafts_user_pseud], posted: false, title: "Other pseud work")
  }

  describe "drafts" do
    let(:other_drafts_user) { create(:user) }

    before do
      fake_login_known_user(drafts_user)
    end

    context "no user_id" do
      it "should redirect to the user controller" do
        get :drafts
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to users_path
      end

      it "should display an appropriate error message" do
        get :drafts
        expect(flash[:error]).to start_with "Whose drafts did you want to look at?"
      end
    end

    context "with a valid user_id" do
      context "if the user_id requested doesn't belong to the current user" do
        it "should display an error" do
          get :drafts, user_id: other_drafts_user.login
          expect(flash[:error]).to eq "You can only see your own drafts, sorry!"
        end

        it "should redirect to the current user's dashboard" do
          get :drafts, user_id: other_drafts_user.login
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to user_path(drafts_user)
        end
      end

      context "if the user_id is that of the current user" do
        it "should display no errors" do
          get :drafts, user_id: drafts_user.login
          expect(flash[:error]).to be_nil
        end

        it "should display all the user's drafts if no pseud_id is specified" do
          get :drafts, user_id: drafts_user.login
          expect(assigns(:works)).to include(other_pseud_work)
          expect(assigns(:works)).to include(default_pseud_work)
        end

        it "should display only the drafts for a specific pseud if a pseud_id is specified" do
          get :drafts, user_id: drafts_user.login, pseud_id: drafts_user_pseud.name
          expect(assigns(:works)).to include(other_pseud_work)
          expect(assigns(:works)).not_to include(default_pseud_work)
        end
      end
    end
  end


  describe "post_draft" do
    before do
      fake_login_known_user(drafts_user)
    end

    it "should display an error if the current user is not the owner of the specified work" do
      random_work = create(:work, posted: false)
      put :post_draft, id: random_work.id
      # There is code to return a different message in the action, but it is unreachable using a web request
      # as the application_controller redirects the user first
      expect(flash[:error]).to start_with "Sorry, you don't have permission to access"
    end

    context "if the work is already posted" do
      it "should display an error" do
        drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: true)
        put :post_draft, id: drafts_user_work.id
        expect(flash[:error]).to eq "That work is already posted. Do you want to edit it instead?"
      end

      it "should redirect to the user work edit page" do
        drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: true)
        put :post_draft, id: drafts_user_work.id
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to edit_user_work_path(drafts_user, drafts_user_work)
      end
    end

    it "should display an error if the work is invalid" do
      drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: false)
      allow_any_instance_of(Work).to receive(:valid?).and_return(false)
      put :post_draft, id: drafts_user_work.id
      expect(flash[:error]).to eq "There were problems posting your work."

      allow_any_instance_of(Work).to receive(:valid?).and_call_original
    end

    it "should display a notice message if the work is in a moderated collection" do
      drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: false)
      draft_collection = create(:collection)
      draft_collection.collection_preference.moderated = true
      drafts_user_work.collections << draft_collection
      controller.instance_variable_set("@collection", draft_collection)
      put :post_draft, id: drafts_user_work.id
      expect(flash[:notice]).to start_with "Work was submitted to a moderated collection."
    end
  end
end
