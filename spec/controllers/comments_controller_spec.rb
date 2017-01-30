require 'spec_helper'

describe CommentsController do
  include LoginMacros

  before(:each) do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe 'comment reviews' do
  
    it "checks that the comment is reviewed and asks that you login" do
      comment = create(:unreviewed_comment)
      get :add_comment_reply, comment_id: comment.id
      expect(response).to redirect_to(login_path)
      expect(flash[:error]).to eq "Sorry, you cannot reply to an unapproved comment."
    end

    it "checks that the comment is reviewed" do
      fake_login
      comment = create(:unreviewed_comment)
      get :add_comment_reply, comment_id: comment.id
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, you cannot reply to an unapproved comment."
    end

    it "checks that the comment right user is reviewing" do
      comment = create(:unreviewed_comment)
      fake_login
      get :unreviewed, comment_id: comment.id
      expect(response).to redirect_to(root_path)
      expect(flash[:error]).to eq "Sorry, you don't have permission to see those unreviewed comments."
    end

    it "checks that there is something to comment on" do
      post :new, tag_id: "Non existant tag"
      expect(flash[:error]).to eq "What did you want to comment on?"
    end

    xit "checks that there is something to review" do
      comment = create(:unreviewed_comment)
      put :review_all, comment_id: comment.id 
      expect(flash[:error]).to eq "What did you want to review comments on?"
      expect(response).to redirect_to(root_path)
    end

    it "can approve a comment" do
      comment = create(:unreviewed_comment)
      put :approve, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: 'comments'))
    end

    it "can hide a comment" do
      comment = create(:unreviewed_comment)
      get :hide_comments, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, anchor: 'comments'))
    end

    it "can add a comment" do
      comment = create(:unreviewed_comment)
      get :add_comment, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, add_comment: true, anchor: 'comments'))
    end

    it "can add a comment reply to comment" do
      comment = create(:comment)
      get :add_comment_reply, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end

    it "can add a comment reply to comment extra" do
      comment = create(:comment)
      get :add_comment_reply, comment_id: comment.id, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, add_comment_reply_id: comment.id, show_comments: true, anchor: "comment_#{comment.id}"))
    end

    it "can cancel a comment" do
      comment = create(:comment)
      get :cancel_comment, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      get :cancel_comment, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
    end

    it "can cancel a comment reply" do
      comment = create(:comment)
      get :cancel_comment_reply, comment_id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
      get :cancel_comment_reply, comment_id: comment.id, show_comments: 'yes', random_option: 'no'
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(comment_path(comment, show_comments: 'yes', anchor: "comments"))
    end

    it "can cancel a request to delete a comment ?" do
      comment = create(:comment)
      get :cancel_comment_delete, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end

    it "can cancel an edit to a comment" do
      comment = create(:comment)
      get :cancel_comment_edit, id: comment.id
      expect(flash[:error]).to be_nil
      expect(response).to redirect_to(work_path(comment.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"))
    end

    it "checks that the owner can delete an unreviewed comment" do
      fake_login
      comment = create(:unreviewed_comment, pseud_id: @current_user.default_pseud.id)
      get :destroy, id: comment.id
      expect(response).to redirect_to("/where_i_came_from")
      expect(flash[:notice]).to eq "Comment deleted."
    end

    it "create a comment on an Admin post" do
      admin_post = create(:admin_post)
      post :new, admin_post_id: admin_post.id
      expect(response).to render_template("new")
    end

    it "create a comment on an fandom" do
      fandom = create(:fandom)
      post :new, tag_id: fandom.name
      expect(response).to render_template("new")
    end

    it "create a new comment on an comment" do
      comment = create(:comment)
      post :new, comment_id: comment.id
      expect(response).to render_template("new")
    end
  end
end
