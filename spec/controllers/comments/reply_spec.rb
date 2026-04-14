require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #add_comment_reply" do
    context "when comment permissions are enable_all" do
      let(:moderated_work) { create(:work, :guest_comments_on, moderated_commenting_enabled: true) }
      let(:unmoderated_work) { create(:work, :guest_comments_on) }

      let(:comment) { create(:comment, commentable: unmoderated_work.first_chapter) }
      let(:unreviewed_comment) { create(:comment, :unreviewed, commentable: moderated_work.first_chapter) }

      context "when comment is unreviewed" do
        it "redirects logged out user to login path with an error" do
          get :add_comment_reply, params: { comment_id: unreviewed_comment.id }
          it_redirects_to_with_error(new_user_session_path(return_to: add_comment_reply_comments_path(comment_id: unreviewed_comment.id)), "Sorry, you cannot reply to an unapproved comment.")
        end

        it "redirects logged in user to root path with an error" do
          fake_login
          get :add_comment_reply, params: { comment_id: unreviewed_comment.id }
          it_redirects_to_with_error(root_path, "Sorry, you cannot reply to an unapproved comment.")
        end
      end

      context "when comment is not unreviewed" do
        it "redirects to the comment on the commentable without an error" do
          get :add_comment_reply, params: { comment_id: comment.id }
          expect(flash[:error]).to be_nil
          expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
        end

        it "redirects to the comment on the commentable with the reply form open and without an error" do
          get :add_comment_reply, params: { comment_id: comment.id, id: comment.id }
          expect(flash[:error]).to be_nil
          expect(response).to redirect_to(chapter_path(comment.commentable, add_comment_reply_id: comment.id, show_comments: true, anchor: "comment_#{comment.id}"))
        end
      end
    end

    shared_examples "no one can add comment reply on a frozen comment" do
      it "redirects logged out user with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a frozen comment.")
      end

      it "redirects logged in user with an error" do
        fake_login
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a frozen comment.")
      end
    end

    context "when comment is frozen" do
      context "when commentable is an admin post" do
        let(:comment) { create(:comment, :on_admin_post, iced: true) }

        it_behaves_like "no one can add comment reply on a frozen comment"
      end

      context "when commentable is a tag" do
        let(:comment) { create(:comment, :on_tag, iced: true) }

        it_behaves_like "no one can add comment reply on a frozen comment"
      end

      context "when commentable is a work" do
        let(:comment) { create(:comment, :on_work_with_guest_comments_on, iced: true) }

        it_behaves_like "no one can add comment reply on a frozen comment"
      end
    end

    shared_examples "no one can add comment reply on a hidden comment" do
      it "redirects logged out user with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a hidden comment.")
      end

      it "redirects logged in user with an error" do
        fake_login
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a hidden comment.")
      end
    end

    context "when comment is hidden by admin" do
      context "when commentable is an admin post" do
        let(:comment) { create(:comment, :on_admin_post, hidden_by_admin: true) }

        it_behaves_like "no one can add comment reply on a hidden comment"
      end

      context "when commentable is a tag" do
        let(:comment) { create(:comment, :on_tag, hidden_by_admin: true) }

        it_behaves_like "no one can add comment reply on a hidden comment"
      end

      context "when commentable is a work with guest comments enabled" do
        let(:comment) { create(:comment, :on_work_with_guest_comments_on, hidden_by_admin: true) }

        it_behaves_like "no one can add comment reply on a hidden comment"
      end
    end

    context "guest comments are turned on in work and admin settings" do
      let(:comment) { create(:comment, :on_work_with_guest_comments_on) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        admin_setting.update_attribute(:guest_comments_off, false)
      end

      it "redirects logged out user to the comment on the commentable without an error" do
        get :add_comment_reply, params: { comment_id: comment.id }

        expect(flash[:error]).to be_nil
        it_redirects_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
      end

      context "when logged in as an admin" do
        before { fake_login_admin(create(:admin)) }

        it "redirects to root with notice prompting log out" do
          get :add_comment_reply, params: { comment_id: comment.id }
          it_redirects_to_with_notice(root_path, "Please log out of your admin account first!")
        end
      end
    end

    context "guest comments are turned off in admin settings" do
      let(:comment) { create(:comment) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }
      let(:work) { comment.ultimate_parent }

      before do
        admin_setting.update_attribute(:guest_comments_off, true)
      end

      [:enable_all, :disable_anon].each do |permissions|
        context "when work comment permissions are #{permissions}" do
          before do
            work.update_attribute(:comment_permissions, permissions)
          end

          it "redirects logged out user with an error" do
            get :add_comment_reply, params: { comment_id: comment.id }
            it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
          end

          it "redirects logged in user to the comment on the commentable without an error" do
            fake_login
            get :add_comment_reply, params: { comment_id: comment.id }
            expect(flash[:error]).to be_nil
            expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
          end
        end
      end

      context "when work comment permissions are disable_all" do
        before do
          work.update_attribute(:comment_permissions, :disable_all)
        end

        it "redirects logged out user with an error" do
          get :add_comment_reply, params: { comment_id: comment.id }
          it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
        end

        it "redirects logged in user with an error" do
          fake_login
          get :add_comment_reply, params: { comment_id: comment.id }
          it_redirects_to_with_error(work_path(work), "Sorry, this work doesn't allow comments.")
        end
      end
    end

    shared_examples "guest cannot reply to a user with guest replies disabled" do
      it "redirects guest with an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, this user doesn't allow non-Archive users to reply to their comments.")
      end

      it "redirects logged in user without an error" do
        fake_login
        get :add_comment_reply, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
      end
    end

    shared_examples "guest can reply to a user with guest replies disabled on user's work" do
      it "redirects guest user without an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
      end

      it "redirects logged in user without an error" do
        fake_login
        get :add_comment_reply, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
      end
    end

    context "when user has guest replies disabled" do
      let(:user) do
        user = create(:user)
        user.preference.update!(guest_replies_off: true)
        user
      end

      context "when commentable is an admin post" do
        let(:comment) { create(:comment, :on_admin_post, pseud: user.default_pseud) }

        it_behaves_like "guest cannot reply to a user with guest replies disabled"
      end

      context "when commentable is a tag" do
        let(:comment) { create(:comment, :on_tag, pseud: user.default_pseud) }

        it_behaves_like "guest cannot reply to a user with guest replies disabled"
      end

      context "when commentable is a work with guest comments enabled" do
        let(:comment) { create(:comment, :on_work_with_guest_comments_on, pseud: user.default_pseud) }

        it_behaves_like "guest cannot reply to a user with guest replies disabled"
      end

      context "when commentable is user's work with guest comments enabled" do
        let(:work) { create(:work, :guest_comments_on, authors: [user.default_pseud]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.first_chapter) }

        it_behaves_like "guest can reply to a user with guest replies disabled on user's work"
      end

      context "when commentable is user's co-creation with guest comments enabled" do
        let(:work) { create(:work, :guest_comments_on, authors: [create(:user).default_pseud, user.default_pseud]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.first_chapter) }

        it_behaves_like "guest can reply to a user with guest replies disabled on user's work"
      end
    end

    context "when replying to guests" do
      let(:comment) { create(:comment, :by_guest, :on_work_with_guest_comments_on) }

      it "redirects guest user without an error" do
        get :add_comment_reply, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
      end

      it "redirects logged in user without an error" do
        fake_login
        get :add_comment_reply, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
        expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, anchor: "comment_#{comment.id}"))
      end
    end
  end

  describe "GET #cancel_comment_reply" do
    context "with only valid params" do
        it "redirects to comment path with the comments anchor and without an error" do
          get :cancel_comment_reply, params: { comment_id: comment.id }
          expect(flash[:error]).to be_nil
          expect(response).to redirect_to(comment_path(comment, anchor: "comments"))
        end
    end

    context "with valid and invalid params" do
        it "removes invalid params and redirects without an error to comment path with valid params and the comments anchor" do
          get :cancel_comment_reply, params: { comment_id: comment.id, show_comments: "yes", random_option: "no" }
          expect(flash[:error]).to be_nil
          expect(response).to redirect_to(comment_path(comment, show_comments: "yes", anchor: "comments"))
        end
    end
  end
end
