# frozen_string_literal: true

require "spec_helper"

describe KudosController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "create" do
    context "when work is public" do
      let(:work) { create(:posted_work) }

      context "when kudos are given from work" do
        it "redirects to referer with a notice" do
          referer = work_path(work)
          request.headers["HTTP_REFERER"] = referer
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_comment_notice(referer, "Thank you for leaving kudos!")
          expect(assigns(:kudo).user).to be_nil
        end
      end

      context "when kudos are given from chapter" do
        it "redirects to referer with a notice" do
          referer = work_chapter_path(work, work.first_chapter)
          request.headers["HTTP_REFERER"] = referer
          post :create, params: { kudo: { commentable_id: work.first_chapter.id, commentable_type: "Chapter" } }
          it_redirects_to_with_comment_notice(referer, "Thank you for leaving kudos!")
          expect(assigns(:kudo).user).to be_nil
        end
      end

      context "when kudos giver is logged in" do
        let(:user) { create(:user) }
        before { fake_login_known_user(user) }

        it "redirects to referer with a notice" do
          referer = work_path(work)
          request.headers["HTTP_REFERER"] = referer
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_comment_notice(referer, "Thank you for leaving kudos!")
          expect(assigns(:kudo).user).to eq(user)
        end
      end

      context "when kudos giver is creator of work" do
        before { fake_login_known_user(work.users.first) }

        it "redirects to referer with an error" do
          referer = work_path(work)
          request.headers["HTTP_REFERER"] = referer
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_comment_error(referer, "You can't leave kudos on your own work.")
        end

        context "with format: :js" do
          it "returns an error in JSON format" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
            expect(JSON.parse(response.body)["errors"]["cannot_be_author"]).to include("^You can't leave kudos on your own work.")
          end
        end
      end
    end

    context "when work does not exist" do
      it "redirects to referer with an error" do
        referer = root_path
        request.headers["HTTP_REFERER"] = referer
        post :create, params: { kudo: { commentable_id: "333", commentable_type: "Work" } }
        it_redirects_to_with_comment_error(referer, "We couldn't save your kudos, sorry!")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: "333", commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["no_commentable"]).to include("^What did you want to leave kudos on?")
        end
      end
    end

    context "when work is restricted" do
      let(:work) { create(:posted_work, restricted: true) }

      it "redirects to referer with an error" do
        referer = work_path(work)
        request.headers["HTTP_REFERER"] = referer
        post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        it_redirects_to_with_comment_error(referer, "You can't leave guest kudos on a restricted work.")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["guest_on_restricted"]).to include("^You can't leave guest kudos on a restricted work.")
        end
      end
    end
  end
end
