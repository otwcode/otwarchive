require 'spec_helper'

describe CommentsController do
  include LoginMacros

  before(:each) do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #add_comment_reply" do
    context "when comment is unreviewed" do
      let(:comment) { create(:unreviewed_comment) }

      it "redirects logged out user to login path with an error" do
        get :add_comment_reply, comment_id: comment.id
        expect(response).to redirect_to(login_path)
        expect(flash[:error]).to eq "Sorry, you cannot reply to an unapproved comment."
      end

      it "redirects logged in user to root path with an error" do
        fake_login
        get :add_comment_reply, comment_id: comment.id
        expect(response).to redirect_to(root_path)
        expect(flash[:error]).to eq "Sorry, you cannot reply to an unapproved comment."
      end
    end

    context "when comment is not unreviewed" do
      let(:comment) { create(:comment) }

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
    it "redirects to root path with an error if logged in user does not own the comment or commentable" do
      comment = create(:unreviewed_comment)
      fake_login
      get :unreviewed, comment_id: comment.id
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, you don't have permission to see those unreviewed comments."
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
    end

    it "renders the :new template if commentable is a valid tag" do
      fandom = create(:fandom)
      post :new, tag_id: fandom.name
      expect(response).to render_template("new")
    end

    it "renders the :new template if commentable is a valid comment" do
      comment = create(:comment)
      post :new, comment_id: comment.id
      expect(response).to render_template("new")
    end
  end

  describe "PUT #review_all" do
    xit "checks that there is something to review" do
      comment = create(:unreviewed_comment)
      put :review_all, comment_id: comment.id 
      expect(flash[:error]).to eq "What did you want to review comments on?"
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PUT #approve" do
    it "redirects to the comment on the commentable without an error" do
      comment = create(:unreviewed_comment)
      put :approve, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: 'comments'))
    end
  end

  describe "GET #hide_comments" do
    it "redirects to the comment path without an error" do
      comment = create(:unreviewed_comment)
      get :hide_comments, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, anchor: 'comments'))
    end
  end

  describe "GET #add_comment" do
    it "redirects to the comment path with add_comment params and without an error" do
      comment = create(:unreviewed_comment)
      get :add_comment, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, add_comment: true, anchor: 'comments'))
    end
  end

  describe "GET #cancel_comment" do
    let(:comment) { create(:comment) }

    context "with only valid params" do
      it "redirects to comment path with the comments anchor and without an error" do
        get :cancel_comment, comment_id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      end
    end

    context "with valid and invalid params" do
      it "removes invalid params and redirects to comment path with valid params and the comments anachor and without an error" do
        get :cancel_comment, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
      end
    end
  end

  describe "GET #cancel_comment_reply" do
    let(:comment) { create(:comment) }

    context "with only valid params" do
      it "redirects to comment path with the comments anchor and without an error" do
        get :cancel_comment_reply, comment_id: comment.id
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      end
    end

    context "with valid and invalid params" do
      it "removes invalid params and redirects to comment path with valid params and the comments anachor and without an error" do
        get :cancel_comment_reply, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
      end
    end
  end

  describe "GET #cancel_comment_delete" do
    it "redirects to the comment on the commentable without an error" do
      comment = create(:comment)
      get :cancel_comment_delete, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end
  end

  describe "GET #cancel_comment_edit" do
    it "redirects to the comment on the commentable without an error" do
      comment = create(:comment)
      get :cancel_comment_edit, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end
  end

  describe "GET #destroy" do
    context "when logged in as the owner of the comment" do
      it "redirects to referrer with a success message" do
        fake_login
        comment = create(:unreviewed_comment, pseud_id: @current_user.default_pseud.id)
        get :destroy, id: comment.id
        expect(response).to redirect_to("/where_i_came_from")
        expect(flash[:notice]).to eq "Comment deleted."
      end
    end
  end
end
