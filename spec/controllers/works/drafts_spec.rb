# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:drafts_user_pseud) { create(:pseud, name: "Visiting User Pseud") }
  let(:drafts_user) do
    user = create(:user)
    user.pseuds << drafts_user_pseud
    user
  end
  let!(:default_pseud_work) do
    create(:work, authors: [drafts_user.default_pseud], posted: false, title: "Default pseud work")
  end
  let!(:other_pseud_work) do
    create(:work, authors: [drafts_user_pseud], posted: false, title: "Other pseud work")
  end

  describe "drafts" do
    let(:other_drafts_user) { create(:user) }

    before do
      fake_login_known_user(drafts_user)
    end

    context "no user_id" do
      it "should redirect to the user controller and display an appropriate error message" do
        get :drafts
        it_redirects_to_with_error(users_path, "Whose drafts did you want to look at?")
      end
    end

    context "with a valid user_id" do
      context "if the user_id requested doesn't belong to the current user" do
        it "displays an error and redirects" do
          get :drafts, params: { user_id: other_drafts_user.login }
          it_redirects_to_with_error(user_path(drafts_user), "You can only see your own drafts, sorry!")
        end
      end

      context "if the user_id is that of the current user" do
        it "should display no errors" do
          get :drafts, params: { user_id: drafts_user.login }
          expect(response).to have_http_status(200)
          expect(flash[:error]).to be_nil
        end

        it "should display all the user's drafts if no pseud_id is specified" do
          get :drafts, params: { user_id: drafts_user.login }
          expect(assigns(:works)).to include(other_pseud_work)
          expect(assigns(:works)).to include(default_pseud_work)
        end

        it "should display only the drafts for a specific pseud if a pseud_id is specified" do
          get :drafts, params: { user_id: drafts_user.login, pseud_id: drafts_user_pseud.name }
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
      put :post_draft, params: { id: random_work.id }
      # There is code to return a different message in the action, but it is unreachable using a web request
      # as the application_controller redirects the user first
      it_redirects_to_with_error(work_path(random_work),
                                 "Sorry, you don't have permission to access the page you were trying to reach.")
    end

    context "if the work is already posted" do
      it "displays an error and redirects" do
        drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: true)
        put :post_draft, params: { id: drafts_user_work.id }
        it_redirects_to_with_error(edit_user_work_path(drafts_user, drafts_user_work),
                                   "That work is already posted. Do you want to edit it instead?")
      end
    end

    it "should display an error and redirect if the work is invalid" do
      drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: false)
      allow_any_instance_of(Work).to receive(:valid?).and_return(false)
      put :post_draft, params: { id: drafts_user_work.id }
      it_redirects_to_with_error(edit_user_work_path(drafts_user, drafts_user_work),
                                 "There were problems posting your work.")
      allow_any_instance_of(Work).to receive(:valid?).and_call_original
    end

    it "should display a notice message and redirect if the work is in a moderated collection" do
      drafts_user_work = create(:work, authors: [drafts_user.default_pseud], posted: false)
      draft_collection = create(:collection)
      draft_collection.collection_preference.moderated = true
      draft_collection.collection_preference.save
      drafts_user_work.collections << draft_collection
      controller.instance_variable_set("@collection", draft_collection)
      put :post_draft, params: { id: drafts_user_work.id }
      it_redirects_to_with_notice(work_path(drafts_user_work),
                                  "Work was submitted to a moderated collection."\
                                  " It will show up in the collection once approved.")
    end
  end
end
