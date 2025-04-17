require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }
  let(:unreviewed_comment) { create(:comment, :unreviewed) }

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #show_comments" do
    context "when the commentable is a valid tag" do
      let(:fandom) { create(:fandom) }

      let(:all_comments_path) do
        comments_path(tag_id: fandom.to_param, anchor: "comments")
      end

      context "when logged in as an admin" do
        before { fake_login_admin(create(:admin)) }

        it "redirects to the tag comments page when the format is html" do
          get :show_comments, params: { tag_id: fandom.name }
          expect(response).to redirect_to all_comments_path
        end

        it "loads the comments when the format is javascript" do
          get :show_comments, params: { tag_id: fandom.name, format: :js }, xhr: true
          expect(response).to render_template(:show_comments)
        end
      end

      context "when logged in as a tag wrangler" do
        before { fake_login_known_user(create(:tag_wrangler)) }

        it "redirects to the tag comments page when the format is html" do
          get :show_comments, params: { tag_id: fandom.name }
          expect(response).to redirect_to all_comments_path
        end

        it "loads the comments when the format is javascript" do
          get :show_comments, params: { tag_id: fandom.name, format: :js }, xhr: true
          expect(response).to render_template(:show_comments)
        end
      end

      context "when logged in as a random user" do
        before { fake_login }

        it "shows an error and redirects" do
          get :show_comments, params: { tag_id: fandom.name }
          it_redirects_to_with_error(user_path(controller.current_user),
                                     "Sorry, you don't have permission to " \
                                     "access the page you were trying to " \
                                     "reach.")
        end
      end

      context "when logged out" do
        before { fake_logout }

        it "shows an error and redirects" do
          get :show_comments, params: { tag_id: fandom.name }
          it_redirects_to_with_error(new_user_session_path,
                                     "Sorry, you don't have permission to " \
                                     "access the page you were trying to " \
                                     "reach. Please log in.")
        end
      end
    end
  end

  describe "GET #hide_comments" do
    it "redirects to the comment path without an error" do
      get :hide_comments, params: { comment_id: unreviewed_comment.id }
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(unreviewed_comment, anchor: "comments"))
    end
  end

  describe "GET #cancel_comment_delete" do
    it "redirects to the comment on the commentable without an error" do
      get :cancel_comment_delete, params: { id: comment.id }
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
    end
  end

  describe "GET #cancel_comment_edit" do
    context "when logged in as the comment writer" do
      before { fake_login_known_user(comment.pseud.user) }

      context "when the format is html" do
        it "redirects to the comment on the commentable without an error" do
          get :cancel_comment_edit, params: { id: comment.id }
          expect(flash[:error]).to be_nil
          expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
        end
      end

      context "when the format is javascript" do
        it "loads the javascript to restore the comment" do
          get :cancel_comment_edit, params: { id: comment.id, format: :js }, xhr: true
          expect(response).to render_template("cancel_comment_edit")
        end
      end
    end

    context "when logged in as a random user" do
      before { fake_login }

      it "shows an error and redirects" do
        get :cancel_comment_edit, params: { id: comment.id }
        it_redirects_to_with_error(comment,
                                   "Sorry, you don't have permission to " \
                                   "access the page you were trying to " \
                                   "reach.")
      end
    end

    context "when logged out" do
      before { fake_logout }

      it "shows an error and redirects" do
        get :cancel_comment_edit, params: { id: comment.id }
        it_redirects_to_with_error(comment,
                                   "Sorry, you don't have permission to " \
                                   "access the page you were trying to " \
                                   "reach. Please log in.")
      end
    end
  end
end
