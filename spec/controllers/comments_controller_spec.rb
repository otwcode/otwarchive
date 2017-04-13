require 'spec_helper'

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }
  let(:unreviewed_comment) { create(:unreviewed_comment) }

  before(:each) do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #add_comment_reply" do
    context "when comment is unreviewed" do
      it "redirects logged out user to login path with an error" do
        get :add_comment_reply, comment_id: unreviewed_comment.id
        it_redirects_to_with_error(login_path, "Sorry, you cannot reply to an unapproved comment.")
      end

      it "redirects logged in user to root path with an error" do
        fake_login
        get :add_comment_reply, comment_id: unreviewed_comment.id
        it_redirects_to_with_error(root_path, "Sorry, you cannot reply to an unapproved comment.")
      end
    end

    context "when comment is not unreviewed" do
      it "redirects to the comment on the commentable without an error" do
        get :add_comment_reply, comment_id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
      end

      it "redirects to the comment on the commentable with the reply form open and without an error" do
        get :add_comment_reply, comment_id: comment.id, id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(work_path(comment.ultimate_parent, add_comment_reply_id: comment.id, show_comments: true, anchor: "comment_#{comment.id}"))
      end
    end
  end

  describe "GET #unreviewed" do
    let!(:user) { create(:user) }
    let!(:work) { create(:work, authors: [user.default_pseud], moderated_commenting_enabled: true ) }
    let(:comment) { create(:unreviewed_comment, commentable_id: work.id) }

    it "redirects logged out users to login path with an error" do
      get :unreviewed, comment_id: comment.id
      it_redirects_to_with_error(login_path, "Sorry, you don't have permission to see those unreviewed comments.")
    end

    it "redirects to root path with an error when logged in user does not own the commentable" do
      fake_login
      get :unreviewed, comment_id: comment.id
      it_redirects_to_with_error(root_path, "Sorry, you don't have permission to see those unreviewed comments.")
    end

    it "renders the :unreviewed template for a user who owns the work" do
      fake_login_known_user(user)
      get :unreviewed, work_id: comment.commentable_id
      expect(response).to render_template("unreviewed")
    end

    it "renders the :unreviewed template for an admin" do
      fake_login_admin(create(:admin))
      get :unreviewed, work_id: comment.commentable_id
      expect(response).to render_template("unreviewed")
    end
  end

  describe "POST #new" do
    it "errors if the commentable is not a valid tag" do
      post :new, tag_id: "Non existent tag"
      expect(flash[:error]).to eq "What did you want to comment on?"
    end

    it "renders the :new template if commentable is a valid admin post" do
      admin_post = create(:admin_post)
      post :new, admin_post_id: admin_post.id
      expect(response).to render_template("new")
      expect(assigns(:name)).to eq(admin_post.title)
    end

    it "renders the :new template if commentable is a valid tag" do
      fandom = create(:fandom)
      post :new, tag_id: fandom.name
      expect(response).to render_template("new")
      expect(assigns(:name)).to eq("Fandom")
    end

    it "renders the :new template if commentable is a valid comment" do
      comment = create(:comment)
      post :new, comment_id: comment.id
      expect(response).to render_template("new")
      expect(assigns(:name)).to eq("Previous Comment")
    end
  end

  describe "PUT #review_all" do
    xit "redirects to root path with an error if current user does not own the commentable" do
      fake_login
      put :review_all, work_id: unreviewed_comment.commentable_id 
      it_redirects_to_with_error(root_path, "What did you want to review comments on?")
    end
  end

  describe "PUT #approve" do
    it "redirects to the comment on the commentable without an error" do
      put :approve, id: unreviewed_comment.id
      expect(unreviewed_comment.approved).to be true
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(unreviewed_comment.ultimate_parent, show_comments: true, anchor: 'comments'))
    end
  end

  describe "GET #hide_comments" do
    it "redirects to the comment path without an error" do
      get :hide_comments, comment_id: unreviewed_comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(unreviewed_comment, anchor: 'comments'))
    end
  end

  describe "GET #add_comment" do
    context "when comment is unreviewed" do
      it "redirects to the comment path with add_comment params and without an error" do
        get :add_comment, comment_id: unreviewed_comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(unreviewed_comment, add_comment: true, anchor: 'comments'))
      end
    end
  end

  describe "GET #cancel_comment" do
    context "with only valid params" do
      it "redirects to comment path with the comments anchor and without an error" do
        get :cancel_comment, comment_id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      end
    end

    context "with valid and invalid params" do
      it "removes invalid params and redirects without an error to comment path with valid params and the comments anchor" do
        get :cancel_comment, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
      end
    end
  end

  describe "GET #cancel_comment_reply" do
    context "with only valid params" do
      it "redirects to comment path with the comments anchor and without an error" do
        get :cancel_comment_reply, comment_id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      end
    end

    context "with valid and invalid params" do
      it "removes invalid params and redirects without an error to comment path with valid params and the comments anchor" do
        get :cancel_comment_reply, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
      end
    end
  end

  describe "GET #cancel_comment_delete" do
    it "redirects to the comment on the commentable without an error" do
      get :cancel_comment_delete, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end
  end

  describe "GET #cancel_comment_edit" do
    it "redirects to the comment on the commentable without an error" do
      get :cancel_comment_edit, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end
  end

  describe "GET #destroy" do
    context "when logged in as the owner of the unreviewed comment" do
      it "deletes the comment and redirects to referrer with a success message" do
        fake_login
        comment = create(:unreviewed_comment, pseud_id: @current_user.default_pseud.id)
        get :destroy, id: comment.id
        expect(Comment.find_by_id(comment.id)).to_not be_present
        expect(response).to redirect_to("/where_i_came_from")
        expect(flash[:notice]).to eq "Comment deleted."
      end
      it "redirects and gives an error if the comment could not be deleted" do
        fake_login
        comment = create(:unreviewed_comment, pseud_id: @current_user.default_pseud.id)
        allow_any_instance_of(Comment).to receive(:destroy_or_mark_deleted).and_return(false)
        get :destroy, id: comment.id
        allow_any_instance_of(Comment).to receive(:destroy_or_mark_deleted).and_call_original
        expect(Comment.find_by_id(comment.id)).to be_present
        expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
        expect(flash[:comment_error]).to eq "We couldn't delete that comment."
      end
    end
  end

  describe "PUT #review" do
    let!(:user) { create(:user) }
    let!(:work) { create(:work, authors: [user.default_pseud], moderated_commenting_enabled: true ) }
    let(:comment) { create(:unreviewed_comment, commentable_id: work.id) }

    before do
      fake_login_known_user(user)
    end

    context "when recipient approves comment from inbox" do
      it "marks comment reviewed and redirects to user inbox path with success message" do
        put :review, id: comment.id, approved_from: "inbox"
        expect(response).to redirect_to(user_inbox_path(user))
        expect(flash[:notice]).to eq "Comment approved."
        comment.reload
        expect(comment.unreviewed).to be false
      end
    end

    context "when recipient approves comment from homepage" do
      it "marks comment reviewed and redirects to root path with success message" do
        put :review, id: comment.id, approved_from: "home"
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq "Comment approved."
        comment.reload
        expect(comment.unreviewed).to be false
      end
    end
  end

  describe "GET #show" do
    it "redirects to root path if logged in user does not have permission to access comment" do
      fake_login
      get :show, id: unreviewed_comment.id
      it_redirects_to_with_error(root_path, "Sorry, that comment is currently in moderation.")
    end
  end

  describe "GET #index" do
    it "errors when not logged in as admin" do
      get :index
      expect(flash[:error]).to eq "Sorry, you don't have permission to access that page."
    end

    it "renders :index template when logged in as admin" do
      fake_login_admin(create(:admin))
      get :index
      expect(response).to render_template("index")
    end
  end
end
