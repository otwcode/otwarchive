require "spec_helper"

describe InboxController do
  include LoginMacros
  include RedirectExpectationHelper
  let(:user) { create(:user) }

  describe "GET #show" do
    it "redirects to user page when not logged in" do
      get :show, user_id: user.login
      it_redirects_to user_path(user)
    end

    it "redirects to user page when logged in as another user" do
      fake_login_known_user(create(:user))
      get :show, user_id: user.login
      it_redirects_to user_path(user)
    end

    context "when logged in as the same user" do
      before { fake_login_known_user(user) }

      it "renders the user inbox" do
        get :show, user_id: user.login
        expect(response).to render_template("show")
        expect(assigns(:inbox_total)).to eq(0)
        expect(assigns(:unread)).to eq(0)
      end

      context "with unread comments" do
        let!(:inbox_comments) do
          Array.new(3) do |i|
            create(:inbox_comment, user: user, created_at: Time.now + i.days)
          end
        end

        it "renders non-zero unread count" do
          get :show, user_id: user.login
          expect(assigns(:inbox_comments)).to eq(inbox_comments.reverse)
          expect(assigns(:inbox_total)).to eq(3)
          expect(assigns(:unread)).to eq(3)
        end

        it "renders oldest first" do
          get :show, user_id: user.login, filters: { date: "asc" }
          expect(assigns(:select_date)).to eq("asc")
          expect(assigns(:inbox_comments)).to eq(inbox_comments)
          expect(assigns(:inbox_total)).to eq(3)
          expect(assigns(:unread)).to eq(3)
        end
      end

      context "with 1 read and 1 unread" do
        let!(:read_comment) { create(:inbox_comment, user: user, read: true) }
        let!(:unread_comment) { create(:inbox_comment, user: user) }

        it "renders only unread" do
          get :show, user_id: user.login, filters: { read: "false" }
          expect(assigns(:select_read)).to eq("false")
          expect(assigns(:inbox_comments)).to eq([unread_comment])
          expect(assigns(:inbox_total)).to eq(2)
          expect(assigns(:unread)).to eq(1)
        end
      end

      context "with 1 replied and 1 unreplied" do
        let!(:replied_comment) { create(:inbox_comment, user: user, replied_to: true) }
        let!(:unreplied_comment) { create(:inbox_comment, user: user) }

        it "renders only unreplied" do
          get :show, user_id: user.login, filters: { replied_to: "false" }
          expect(assigns(:select_replied_to)).to eq("false")
          expect(assigns(:inbox_comments)).to eq([unreplied_comment])
          expect(assigns(:inbox_total)).to eq(2)
          expect(assigns(:unread)).to eq(2)
        end
      end

      context "with a deleted comment" do
        let(:inbox_comment) { create(:inbox_comment, user: user) }

        it "excludes deleted comments" do
          inbox_comment.feedback_comment.destroy
          get :show, user_id: user.login
          expect(assigns(:inbox_total)).to eq(0)
          expect(assigns(:unread)).to eq(0)
        end
      end
    end
  end

  describe "GET #reply" do
    let(:inbox_comment) { create(:inbox_comment) }
    let(:feedback_comment) { inbox_comment.feedback_comment }

    before { fake_login_known_user(inbox_comment.user) }

    it "renders the HTML form" do
      get :reply, user_id: inbox_comment.user.login, comment_id: feedback_comment.id
      path_params = {
        add_comment_reply_id: feedback_comment.id,
        anchor: "comment_" + feedback_comment.id.to_s
      }
      it_redirects_to comment_path(feedback_comment, path_params)
      expect(assigns(:commentable)).to eq(feedback_comment)
      expect(assigns(:comment)).to be_a_new(Comment)
    end

    it "renders the JS form" do
      get :reply, user_id: inbox_comment.user.login, comment_id: feedback_comment.id, format: "js"
      expect(response).to render_template("reply")
      expect(assigns(:commentable)).to eq(feedback_comment)
      expect(assigns(:comment)).to be_a_new(Comment)
    end
  end

  describe "PUT #update" do
    before { fake_login_known_user(user) }

    context "with no comments selected" do
      it "redirects to inbox with caution" do
        put :update, user_id: user.login, read: "yeah"
        it_redirects_to_with_caution user_inbox_path(user), "Please select something first"
        # A notice also appears!
        expect(flash[:notice]).to eq("Inbox successfully updated.")
      end

      it "redirects to the previously viewed page if HTTP_REFERER is set" do
        @request.env['HTTP_REFERER'] = root_path
        put :update, user_id: user.login, read: "yeah"
        it_redirects_to_with_caution root_path, "Please select something first"
      end
    end

    context "with unread comments" do
      let!(:inbox_comment_1) { create(:inbox_comment, user: user) }
      let!(:inbox_comment_2) { create(:inbox_comment, user: user) }

      it "marks all as read" do
        put :update, user_id: user.login, inbox_comments: [inbox_comment_1.id, inbox_comment_2.id], read: "yeah"
        it_redirects_to_with_notice user_inbox_path(user), "Inbox successfully updated."

        inbox_comment_1.reload
        expect(inbox_comment_1.read).to be_truthy
        inbox_comment_2.reload
        expect(inbox_comment_2.read).to be_truthy
      end

      it "marks one as read" do
        put :update, user_id: user.login, inbox_comments: [inbox_comment_1.id], read: "yeah"
        it_redirects_to_with_notice user_inbox_path(user), "Inbox successfully updated."

        inbox_comment_1.reload
        expect(inbox_comment_1.read).to be_truthy
        inbox_comment_2.reload
        expect(inbox_comment_2.read).to be_falsy
      end

      it "deletes one" do
        put :update, user_id: user.login, inbox_comments: [inbox_comment_1.id], delete: "yeah"
        it_redirects_to_with_notice user_inbox_path(user), "Inbox successfully updated."

        expect(InboxComment.find_by_id(inbox_comment_1.id)).to be_nil
        inbox_comment_2.reload
        expect(inbox_comment_2.read).to be_falsy
      end
    end

    context "with a read comment" do
      let!(:inbox_comment) { create(:inbox_comment, user: user, read: true) }

      it "marks as unread" do
        put :update, user_id: user.login, inbox_comments: [inbox_comment.id], unread: "yeah"
        it_redirects_to_with_notice user_inbox_path(user), "Inbox successfully updated."

        inbox_comment.reload
        expect(inbox_comment.read).to be_falsy
      end

      it "marks as unread and returns a JSON response" do
        put :update, user_id: user.login, inbox_comments: [inbox_comment.id], unread: "yeah", format: "json"

        inbox_comment.reload
        expect(inbox_comment.read).to be_falsy

        parsed_body = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_body[:item_success_message]).to eq("Inbox successfully updated.")
        expect(response).to have_http_status(:success)
      end
    end
  end
end
