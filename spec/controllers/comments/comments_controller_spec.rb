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
          it_redirects_to_user_login_with_error
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

  shared_examples "no one can add or edit comments" do
    let(:anon_comment_attributes) do
      attributes_for(:comment, :by_guest).slice(:name, :email, :comment_content)
    end

    context "when logged out" do
      it "DELETE #destroy redirects to the home page with an error" do
        delete :destroy, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #add_comment_reply redirects to the home page with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #index redirects to the home page with an error" do
        get :index, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #new (on a comment) redirects to the home page with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #new redirects to the home page with an error" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #show redirects to the home page with an error" do
        get :show, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "GET #show_comments redirects to the home page with an error" do
        get :show_comments, params: { work_id: work.id, format: :js }, xhr: true
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "POST #create (on a comment) redirects to the home page with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "POST #create redirects to the home page with an error" do
        post :create, params: { work_id: work.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "PUT #freeze redirects to the home page with an error" do
        put :freeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end

      it "PUT #unfreeze redirects to the home page with an error" do
        put :unfreeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
      end
    end

    context "when logged in as a random user" do
      before { fake_login }

      it "DELETE #destroy redirects to the home page with an error" do
        delete :destroy, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #add_comment_reply redirects to the home page with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #index redirects to the home page with an error" do
        get :index, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #new (on a comment) redirects to the home page with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #new redirects to the home page with an error" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #show redirects to the home page with an error" do
        get :show, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #show_comments redirects to the home page with an error" do
        get :show_comments, params: { work_id: work.id, format: :js }, xhr: true
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "POST #create (on a comment) redirects to the home page with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "POST #create redirects to the home page with an error" do
        post :create, params: { work_id: work.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "PUT #freeze redirects to the home page with an error" do
        put :freeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "PUT #unfreeze redirects to the home page with an error" do
        put :unfreeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as the comment writer" do
      before { fake_login_known_user(comment.pseud.user) }

      it "DELETE #destroy redirects to the home page with an error" do
        delete :destroy, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #add_comment_reply redirects to the home page with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #new redirects to the home page with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "GET #show redirects to the home page with an error" do
        get :show, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "POST #create redirects to the home page with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "PUT #freeze redirects to the home page with an error" do
        put :freeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end

      it "PUT #unfreeze redirects to the home page with an error" do
        put :unfreeze, params: { id: comment.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to access the page you were trying to reach.")
      end
    end

    context "when logged in as the work's owner" do
      before { fake_login_known_user(work.users.first) }

      it "DELETE #destroy successfully deletes the comment" do
        delete :destroy, params: { id: comment.id }
        expect(flash[:comment_notice]).to eq "Comment deleted."
        it_redirects_to_simple(work_path(work, show_comments: true, anchor: :comments))
        expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "GET #add_comment_reply redirects to the work with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #index renders the index template" do
        get :index, params: { work_id: work.id }
        expect(response).to render_template(:index)
      end

      it "GET #new (on a comment) redirects to the work with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #new redirects to the work with an error" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #show_comments renders the show_comments template" do
        get :show_comments, params: { work_id: work.id, format: :js }, xhr: true
        expect(response).to render_template(:show_comments)
      end

      it "GET #show successfully displays the comment" do
        get :show, params: { id: comment.id }
        expect(response).to render_template(:show)
        expect(assigns[:comment]).to eq(comment)
      end

      it "POST #create (on a comment) redirects to the work with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "POST #create redirects to the work with an error" do
        post :create, params: { work_id: work.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "PUT #freeze successfully freezes the comment" do
        put :freeze, params: { id: comment.id }
        it_redirects_to_with_comment_notice(
          work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
          "Comment thread successfully frozen!"
        )
        expect(comment.reload.iced).to be_truthy
      end

      it "PUT #unfreeze successfully unfreezes the comment" do
        comment.update!(iced: true)
        put :unfreeze, params: { id: comment.id }
        it_redirects_to_with_comment_notice(
          work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
          "Comment thread successfully unfrozen!"
        )
        expect(comment.reload.iced).to be_falsey
      end
    end

    context "when logged in as an admin" do
      before { fake_login_admin(create(:admin, roles: ["policy_and_abuse"])) }

      let(:admin) { create(:admin) }

      context "DELETE #destroy" do
        it "does not permit deletion of the comment when admin has no role" do
          admin.update!(roles: [])
          fake_login_admin(admin)
          delete :destroy, params: { id: comment.id }
          it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
        end

        %w[superadmin board legal support policy_and_abuse].each do |admin_role|
          it "successfully deletes the comment when admin has #{admin_role} role" do
            admin.update!(roles: [admin_role])
            fake_login_admin(admin)
            delete :destroy, params: { id: comment.id }
            expect(flash[:comment_notice]).to eq "Comment deleted."
            it_redirects_to_simple(work_path(work, show_comments: true, anchor: :comments))
            expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
          end
        end
      end

      it "GET #add_comment_reply redirects to the work with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #index renders the index template" do
        get :index, params: { work_id: work.id }
        expect(response).to render_template(:index)
      end

      it "GET #new (on a comment) redirects to the work with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #new redirects to the work with an error" do
        get :new, params: { work_id: work.id }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "GET #show_comments renders the show_comments template" do
        get :show_comments, params: { work_id: work.id, format: :js }, xhr: true
        expect(response).to render_template(:show_comments)
      end

      it "GET #show successfully displays the comment" do
        get :show, params: { id: comment.id }
        expect(response).to render_template(:show)
        expect(assigns[:comment]).to eq(comment)
      end

      it "POST #create (on a comment) redirects to the work with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      it "POST #create redirects to the work with an error" do
        post :create, params: { work_id: work.id, comment: anon_comment_attributes }
        it_redirects_to_with_error(work_path(work), edit_error_message)
      end

      context "PUT #freeze" do
        it "does not permit freezing of the comment when admin has no role" do
          admin.update!(roles: [])
          fake_login_admin(admin)
          put :freeze, params: { id: comment.id }
          it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
        end

        %w[superadmin policy_and_abuse].each do |admin_role|
          it "successfully freezes the comment when admin has #{admin_role} role" do
            admin.update!(roles: [admin_role])
            fake_login_admin(admin)
            put :freeze, params: { id: comment.id }
            it_redirects_to_with_comment_notice(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully frozen!"
            )
            expect(comment.reload.iced).to be_truthy
          end
        end
      end

      context "PUT #unfreeze" do
        it "does not permit unfreezing of the comment when admin has no role" do
          comment.update!(iced: true)
          admin.update!(roles: [])
          fake_login_admin(admin)
          put :unfreeze, params: { id: comment.id }
          it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
        end

        %w[superadmin policy_and_abuse].each do |admin_role|
          it "successfully unfreezes the comment when admin has #{admin_role} role" do
            comment.update!(iced: true)
            admin.update!(roles: [admin_role])
            fake_login_admin(admin)
            put :unfreeze, params: { id: comment.id }
            it_redirects_to_with_comment_notice(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully unfrozen!"
            )
            expect(comment.reload.iced).to be_falsey
          end
        end
      end
    end
  end

  context "on a work hidden by an admin" do
    it_behaves_like "no one can add or edit comments" do
      let(:edit_error_message) { "Sorry, you can't add or edit comments on a hidden work." }
      let(:work) { comment.ultimate_parent }
      before { work.update_column(:hidden_by_admin, true) }
    end
  end

  context "on an unrevealed work" do
    it_behaves_like "no one can add or edit comments" do
      let(:edit_error_message) { "Sorry, you can't add or edit comments on an unrevealed work." }
      let(:work) { comment.ultimate_parent }
      before { work.update!(collection_names: create(:unrevealed_collection).name) }
    end
  end
end
