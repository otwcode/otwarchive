require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }
  let(:unreviewed_comment) { create(:comment, :unreviewed) }

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #new" do
    it "errors if the commentable is not a valid tag" do
      get :new, params: { tag_id: "Non existent tag" }
      expect(flash[:error]).to eq "What did you want to comment on?"
    end

    it "renders the :new template if commentable is a valid admin post" do
      admin_post = create(:admin_post, comment_permissions: :enable_all)
      get :new, params: { admin_post_id: admin_post.id }
      expect(response).to render_template("new")
      expect(assigns(:name)).to eq(admin_post.title)
      expect(assigns[:page_subtitle]).to eq("New Comment on #{admin_post.title}")
    end

    context "when the commentable is a valid tag" do
      let(:fandom) { create(:fandom) }

      context "when logged in as an admin" do
        before { fake_login_admin(create(:admin)) }

        it "redirects to root with notice prompting log out" do
          get :new, params: { tag_id: fandom.name }
          it_redirects_to_with_notice(root_path, "Please log out of your admin account first!")
        end
      end

      context "when logged in as a tag wrangler" do
        before { fake_login_known_user(create(:tag_wrangler)) }

        it "renders the :new template" do
          get :new, params: { tag_id: fandom.name }
          expect(response).to render_template("new")
          expect(assigns(:name)).to eq("Fandom")
        end

        it "assigns page subtitle using tag name" do
          get :new, params: { tag_id: fandom.name }
          expect(assigns[:page_subtitle]).to eq("New Comment on #{fandom.name}")
        end
      end

      context "when logged in as a random user" do
        before { fake_login }

        it "shows an error and redirects" do
          get :new, params: { tag_id: fandom.name }
          it_redirects_to_with_error(user_path(controller.current_user),
                                     "Sorry, you don't have permission to " \
                                     "access the page you were trying to " \
                                     "reach.")
        end
      end

      context "when logged out" do
        before { fake_logout }

        it "shows an error and redirects" do
          get :new, params: { tag_id: fandom.name }
          it_redirects_to_user_login_with_error
        end
      end
    end

    context "guest comments are turned on in admin settings" do
      let(:work) { create(:work) }
      let(:work_with_guest_comment_on) { create(:work, :guest_comments_on) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        admin_setting.update_attribute(:guest_comments_off, false)
      end

      it "does not allow guest comments" do
        get :new, params: { work_id: work.id }

        it_redirects_to_with_error(work_path(work),
                                    "Sorry, this work doesn't allow non-Archive users to comment.")
      end

      it "allows guest comments when work has guest comments enabled" do
        get :new, params: { work_id: work_with_guest_comment_on.id }

        expect(response).to render_template(:new)
        expect(assigns[:page_subtitle]).to eq("New Comment on #{work_with_guest_comment_on.title} - #{work_with_guest_comment_on.pseuds.first.byline} - #{work_with_guest_comment_on.fandoms.first.name}")
      end
    end

    context "guest comments are turned off in admin settings" do
      let(:work) { create(:work) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        admin_setting.update_attribute(:guest_comments_off, true)
      end

      [:enable_all, :disable_anon].each do |permissions|
        context "when work comment permissions are #{permissions}" do
          before do
            work.update_attribute(:comment_permissions, permissions)
          end

          it "redirects logged out user with an error" do
            get :new, params: { work_id: work.id }
            it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
          end

          it "renders the :new template for logged in user" do
            fake_login
            get :new, params: { work_id: work.id }
            expect(flash[:error]).to be_nil
            expect(response).to render_template("new")
          end
        end
      end

      context "when work comment permissions are disable_all" do
        before do
            work.update_attribute(:comment_permissions, :disable_all)
        end

        it "redirects logged out user with an error" do
          get :new, params: { work_id: work.id }
          it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
        end

        it "redirects logged in user with an error" do
          fake_login
          get :new, params: { work_id: work.id }
          it_redirects_to_with_error(work_path(work), "Sorry, this work doesn't allow comments.")
        end
      end
    end

    context "when work comment permissions are enable_all" do
      let(:work) { create(:work, :guest_comments_on) }

      it "renders the :new template if commentable is a valid comment" do
        comment = create(:comment, commentable: work)
        get :new, params: { comment_id: comment.id }
        expect(response).to render_template("new")
        expect(assigns(:name)).to eq("Previous Comment")
        expect(assigns[:page_subtitle]).to eq("New Comment on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
      end

      it "shows an error and redirects if commentable is a frozen comment" do
        comment = create(:comment, iced: true, commentable: work)
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a frozen comment.")
      end

      it "shows an error and redirects if commentable is a hidden comment" do
        comment = create(:comment, hidden_by_admin: true, commentable: work)
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a hidden comment.")
      end
    end

    shared_examples "guest cannot reply to a user with guest replies disabled" do
      it "redirects guest with an error" do
        get :new, params: { comment_id: comment.id }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, this user doesn't allow non-Archive users to reply to their comments.")
      end

      it "renders the :new template for logged in user" do
        fake_login
        get :new, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
        expect(response).to render_template("new")
      end
    end

    shared_examples "guest can reply to a user with guest replies disabled on user's work" do
      it "renders the :new template for guest" do
        get :new, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
        expect(response).to render_template("new")
      end

      it "renders the :new template for logged in user" do
        fake_login
        get :new, params: { comment_id: comment.id }
        expect(flash[:error]).to be_nil
        expect(response).to render_template("new")
      end
    end

    context "user has guest comment replies disabled" do
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

      context "when comment is on user's work with guest comments enabled" do
        let(:work) { create(:work, :guest_comments_on, authors: [user.default_pseud]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.first_chapter) }

        it_behaves_like "guest can reply to a user with guest replies disabled on user's work"
      end

      context "when commentable is user's co-creation" do
        let(:work) { create(:work, :guest_comments_on, authors: [create(:user).default_pseud, user.default_pseud]) }
        let(:comment) { create(:comment, pseud: user.default_pseud, commentable: work.first_chapter) }

        it_behaves_like "guest can reply to a user with guest replies disabled on user's work"
      end
    end
  end

  describe "POST #create" do
    let(:anon_comment_attributes) do
      attributes_for(:comment, :by_guest).slice(:name, :email, :comment_content)
    end

    context "when replying from the inbox" do
      let!(:user) { create(:user) }
      let!(:comment) { create(:comment) }

      before do
        fake_login_known_user(user)
        request.env["HTTP_REFERER"] = user_inbox_path(user)
      end

      it "creates the reply and redirects to user inbox path" do
        comment_attributes = {
          pseud_id: user.default_pseud_id,
          comment_content: "Hello fellow human!"
        }
        post :create, params: { comment_id: comment.id, comment: comment_attributes, filters: { date: "asc" } }
        expect(response).to redirect_to(user_inbox_path(user, filters: { date: "asc" }))
        expect(flash[:comment_notice]).to eq "Comment created!"
      end
    end

    context "when the commentable is a valid tag" do
      let(:fandom) { create(:fandom) }

      context "when logged in as an admin" do
        before { fake_login_admin(create(:admin)) }

        it "redirects to root with notice prompting log out" do
          post :create, params: { tag_id: fandom.name, comment: anon_comment_attributes }
          it_redirects_to_with_notice(root_path, "Please log out of your admin account first!")
          comment = Comment.last
          expect(comment).to eq nil
        end
      end

      context "when logged in as a tag wrangler" do
        before { fake_login_known_user(create(:tag_wrangler)) }

        it "posts the comment and shows it in context" do
          post :create, params: { tag_id: fandom.name, comment: anon_comment_attributes }
          comment = Comment.last
          expect(comment.commentable).to eq fandom
          expect(comment.name).to eq anon_comment_attributes[:name]
          expect(comment.email).to eq anon_comment_attributes[:email]
          expect(comment.comment_content).to include anon_comment_attributes[:comment_content]
          path = comments_path(tag_id: fandom.to_param,
                               anchor: "comment_#{comment.id}")
          expect(response).to redirect_to path
        end
      end

      context "when logged in as a random user" do
        before { fake_login }

        it "shows an error and redirects" do
          post :create, params: { tag_id: fandom.name, comment: anon_comment_attributes }
          it_redirects_to_with_error(user_path(controller.current_user),
                                     "Sorry, you don't have permission to " \
                                     "access the page you were trying to " \
                                     "reach.")
        end
      end

      context "when logged out" do
        before { fake_logout }

        it "shows an error and redirects" do
          post :create, params: { tag_id: fandom.name, comment: anon_comment_attributes }
          it_redirects_to_user_login_with_error
        end
      end
    end

    context "when the commentable is a work" do
      context "when the work is restricted" do
        let(:work) { create(:work, restricted: true) }

        it "redirects to the login page" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          it_redirects_to(new_user_session_path(restricted_commenting: true, return_to: request.fullpath))
        end
      end

      context "when the work has all comments disabled" do
        let(:work) { create(:work, comment_permissions: :disable_all) }

        it "shows an error and redirects" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          it_redirects_to_with_error(work_path(work),
                                     "Sorry, this work doesn't allow comments.")
        end

        it "sets flash_is_set to bypass caching" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          expect(cookies[:flash_is_set]).to eq("1")
        end
      end

      context "when the work has anonymous comments disabled" do
        let(:work) { create(:work, comment_permissions: :disable_anon) }

        it "shows an error and redirects" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          it_redirects_to_with_error(work_path(work),
                                     "Sorry, this work doesn't allow non-Archive users to comment.")
        end

        it "sets flash_is_set to bypass caching" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          expect(cookies[:flash_is_set]).to eq("1")
        end
      end

      context "when logged in as an admin" do
        let(:work) { create(:work, :guest_comments_on) }

        before { fake_login_admin(create(:admin)) }

        it "redirects to root with notice prompting log out" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          it_redirects_to_with_notice(root_path, "Please log out of your admin account first!")
        end
      end
    end

    context "when the commentable is an admin post" do
      context "where all comments are disabled" do
        let(:admin_post) { create(:admin_post, comment_permissions: :disable_all) }

        it "shows an error and redirects" do
          post :create, params: { admin_post_id: admin_post.id, comment: anon_comment_attributes }
          it_redirects_to_with_error(admin_post_path(admin_post),
                                     "Sorry, this news post doesn't allow comments.")
        end
      end

      context "where anonymous comments are disabled" do
        let(:admin_post) { create(:admin_post, comment_permissions: :disable_anon) }

        it "shows an error and redirects" do
          post :create, params: { admin_post_id: admin_post.id, comment: anon_comment_attributes }
          it_redirects_to_with_error(admin_post_path(admin_post),
                                     "Sorry, this news post doesn't allow non-Archive users to comment.")
        end
      end
    end

    context "when the commentable is a comment" do
      context "on a parent work" do
        context "where all comments are disabled" do
          let(:work) { create(:work, comment_permissions: :disable_all) }
          let(:comment) { create(:comment, commentable: work.first_chapter) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error(work_path(work),
                                       "Sorry, this work doesn't allow comments.")
          end
        end

        context "where anonymous comments are disabled" do
          let(:work) { create(:work, comment_permissions: :disable_anon) }
          let(:comment) { create(:comment, commentable: work.first_chapter) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error(work_path(work),
                                       "Sorry, this work doesn't allow non-Archive users to comment.")
          end
        end
      end

      context "on an admin post" do
        context "where all comments are disabled" do
          let(:admin_post) { create(:admin_post, comment_permissions: :disable_all) }
          let(:comment) { create(:comment, commentable: admin_post) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error(admin_post_path(admin_post),
                                       "Sorry, this news post doesn't allow comments.")
          end
        end

        context "where anonymous comments are disabled" do
          let(:admin_post) { create(:admin_post, comment_permissions: :disable_anon) }
          let(:comment) { create(:comment, commentable: admin_post) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error(admin_post_path(admin_post),
                                       "Sorry, this news post doesn't allow non-Archive users to comment.")
          end
        end
      end

      context "with guest comments enabled" do
        let(:work_with_guest_comment_on) { create(:work, :guest_comments_on) }

        context "when the commentable is frozen" do
          let(:comment) { create(:comment, iced: true, commentable: work_with_guest_comment_on) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a frozen comment.")
          end
        end

        context "when the commentable is hidden" do
          let(:comment) { create(:comment, hidden_by_admin: true, commentable: work_with_guest_comment_on) }

          it "shows an error and redirects" do
            post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you cannot reply to a hidden comment.")
          end
        end

        context "when the commentable is spam" do
          let(:spam_comment) { create(:comment, commentable: work_with_guest_comment_on) }

          before do
            spam_comment.update_attribute(:approved, false)
            spam_comment.update_attribute(:spam, true)
          end

          it "shows an error and redirects if commentable is a comment marked as spam" do
            post :create, params: { comment_id: spam_comment.id, comment: anon_comment_attributes }

            it_redirects_to_with_error("/where_i_came_from", "Sorry, you can't reply to a comment that has been marked as spam.")
          end
        end
      end
    end

    context "guest comments are turned on in admin settings" do
      let(:work) { create(:work, :guest_comments_on) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        admin_setting.update_attribute(:guest_comments_off, false)
      end

      it "allows guest comments when work has guest comments enabled" do
        post :create, params: { work_id: work.id, comment: anon_comment_attributes }

        expect(flash[:error]).to be_nil
      end
    end

    context "guest comments are turned off in admin settings" do
      let(:work) { create(:work) }
      let(:user) { create(:user) }
      let(:admin_setting) { AdminSetting.first || AdminSetting.create }

      before do
        admin_setting.update_attribute(:guest_comments_off, true)
      end

      [:enable_all, :disable_anon].each do |permissions|
        context "when work comment permissions are #{permissions}" do
          before do
            work.update_attribute(:comment_permissions, permissions)
          end

          it "redirects logged out user with an error" do
            post :create, params: { work_id: work.id, comment: anon_comment_attributes }
            it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
          end

          it "redirects logged in user to the comment on the commentable without an error" do
            comment_attributes = {
              pseud_id: user.default_pseud_id,
              comment_content: "Hello fellow human!"
            }
            fake_login_known_user(user)
            post :create, params: { work_id: work.id, comment: comment_attributes }
            comment = Comment.last
            expect(flash[:error]).to be_nil
            expect(response).to redirect_to(chapter_path(comment.commentable, show_comments: true, view_full_work: false, anchor: "comment_#{comment.id}"))
          end
        end
      end

      context "when work comment permissions are disable_all" do
        before do
          work.update_attribute(:comment_permissions, :disable_all)
        end

        it "redirects logged out user with an error" do
          post :create, params: { work_id: work.id, comment: anon_comment_attributes }
          it_redirects_to_with_error("/where_i_came_from", "Sorry, the Archive doesn't allow guests to comment right now.")
        end

        it "redirects logged in user with an error" do
          comment_attributes = {
            pseud_id: user.default_pseud_id,
            comment_content: "Hello fellow human!"
          }
          fake_login_known_user(user)
          post :create, params: { work_id: work.id, comment: comment_attributes }
          it_redirects_to_with_error(work_path(work), "Sorry, this work doesn't allow comments.")
        end
      end
    end

    shared_examples "guest cannot reply to a user with guest replies disabled" do
      it "redirects guest with an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        it_redirects_to_with_error("/where_i_came_from", "Sorry, this user doesn't allow non-Archive users to reply to their comments.")
      end

      it "redirects logged in user without an error" do
        comment_attributes = {
          pseud_id: user.default_pseud_id,
          comment_content: "Hello fellow human!"
        }
        fake_login_known_user(user)
        post :create, params: { comment_id: comment.id, comment: comment_attributes }
        expect(flash[:error]).to be_nil
      end
    end

    shared_examples "guest can reply to a user with guest replies disabled on user's work" do
      it "redirects guest without an error" do
        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
        expect(flash[:error]).to be_nil
      end

      it "redirects logged in user without an error" do
        comment_attributes = {
          pseud_id: user.default_pseud_id,
          comment_content: "Hello fellow human!"
        }
        fake_login_known_user(user)
        post :create, params: { comment_id: comment.id, comment: comment_attributes }
        expect(flash[:error]).to be_nil
      end
    end

    context "user has guest comment replies disabled" do
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

      context "when comment is on user's work with guest comments enabled" do
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

    context "with unusual user agents" do
      let(:work) { create(:work) }
      let(:user) { create(:user) }

      context "when the user agent is very long" do
        before do
          request.env["HTTP_USER_AGENT"] = "Mozilla/5.0 (X11; Linux x86_64; rv:138.0) Gecko/20100101 Firefox/138.0" * 10
        end

        it "creates the comment with a truncated user agent" do
          comment_attributes = {
            pseud_id: user.default_pseud_id,
            comment_content: "I love this!"
          }
          fake_login_known_user(user)
          post :create, params: { work_id: work.id, comment: comment_attributes }
          comment = assigns[:comment]
          it_redirects_to_with_comment_notice(chapter_path(comment.commentable, show_comments: true, view_full_work: false, anchor: "comment_#{comment.id}"), "Comment created!")
          expect(comment.user_agent.length).to eq(500)
        end
      end

      context "when no user agent is set" do
        before do
          request.env["HTTP_USER_AGENT"] = nil
        end

        it "creates the comment with no user agent" do
          comment_attributes = {
            pseud_id: user.default_pseud_id,
            comment_content: "I love this!"
          }
          fake_login_known_user(user)
          post :create, params: { work_id: work.id, comment: comment_attributes }
          comment = assigns[:comment]
          it_redirects_to_with_comment_notice(chapter_path(comment.commentable, show_comments: true, view_full_work: false, anchor: "comment_#{comment.id}"), "Comment created!")
          expect(comment.user_agent).to be_nil
        end
      end
    end

    context "when cloudflare headers are available" do
      let!(:comment) { create(:comment) }
      before { fake_login }

      it "sets the bot score" do
        request.env["HTTP_CF_BOT_SCORE"] = "42"
        expect_any_instance_of(Comment).to receive(:cloudflare_bot_score=).with("42")

        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
      end

      it "sets the ja3 hash" do
        request.env["HTTP_CF_JA3_HASH"] = "a_hash"
        expect_any_instance_of(Comment).to receive(:cloudflare_ja3_hash=).with("a_hash")

        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
      end

      it "sets the ja3 hash" do
        request.env["HTTP_CF_JA4"] = "another_hash"
        expect_any_instance_of(Comment).to receive(:cloudflare_ja4=).with("another_hash")

        post :create, params: { comment_id: comment.id, comment: anon_comment_attributes }
      end
    end
  end

  describe "DELETE #destroy" do
    context "when logged in as the owner of the unreviewed comment" do
      before { fake_login_known_user(unreviewed_comment.pseud.user) }

      it "deletes the comment and redirects to referer with a notice" do
        delete :destroy, params: { id: unreviewed_comment.id }
        expect do
          unreviewed_comment.reload
        end.to raise_exception(ActiveRecord::RecordNotFound)
        it_redirects_to_with_notice("/where_i_came_from", "Comment deleted.")
      end

      it "redirects and gives an error if the comment could not be deleted" do
        allow_any_instance_of(Comment).to receive(:destroy_or_mark_deleted).and_return(false)
        delete :destroy, params: { id: unreviewed_comment.id }
        expect(unreviewed_comment.reload).to be_present
        expect(response).to redirect_to(chapter_path(unreviewed_comment.commentable, show_comments: true, anchor: "comment_#{unreviewed_comment.id}"))
        expect(flash[:comment_error]).to eq "We couldn't delete that comment."
      end
    end

    context "when comment is a guest reply to user who turns off guest replies afterwards" do
      let(:comment) { create(:comment, :on_admin_post) }
      let(:reply) do
        reply = create(:comment, :by_guest, commentable: comment)
        comment.user.preference.update!(guest_replies_off: true)
        reply
      end

      it "deletes the reply and redirects with success message" do
        admin = create(:admin)
        admin.update!(roles: ["superadmin"])
        fake_login_admin(admin)
        delete :destroy, params: { id: reply.id }

        it_redirects_to_with_comment_notice(
          admin_post_path(reply.ultimate_parent, show_comments: true, anchor: "comment_#{comment.id}"),
          "Comment deleted."
        )
        expect do
          reply.reload
        end.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "when comment is frozen" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post, iced: true) }

        context "when logged out" do
          it "doesn't destroy comment and redirects with error" do
            delete :destroy, params: { id: comment.id }

            it_redirects_to_with_error(comment, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
            expect { comment.reload }.not_to raise_exception
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't destroy comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              delete :destroy, params: { id: comment.id }

              it_redirects_to_with_error(root_url, "Sorry, only an authorized admin can access the page you were trying to reach.")
              expect { comment.reload }.not_to raise_exception
            end
          end

          %w[superadmin board board_assistants_team communications elections legal policy_and_abuse support].each do |admin_role|
            context "with role #{admin_role}" do
              it "destroys comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                delete :destroy, params: { id: comment.id }

                expect(flash[:comment_notice]).to eq("Comment deleted.")
                it_redirects_to_simple(admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments))
                expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
              end
            end
          end
        end

        context "when logged in as a user" do
          context "when user does not own comment" do
            it "doesn't destroy comment and redirects with error" do
              fake_login
              delete :destroy, params: { id: comment.id }

              it_redirects_to_with_error(comment, "Sorry, you don't have permission to access the page you were trying to reach.")
              expect { comment.reload }.not_to raise_exception
            end
          end

          context "when user owns comment" do
            it "destroys comment and redirects with success message" do
              fake_login_known_user(comment.pseud.user)
              delete :destroy, params: { id: comment.id }

              expect(flash[:comment_notice]).to eq("Comment deleted.")
              it_redirects_to_simple(admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments))
              expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
            end
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag, iced: true) }

        context "when logged out" do
          it "doesn't destroy comment and redirects with error" do
            delete :destroy, params: { id: comment.id }

            it_redirects_to_user_login_with_error
            expect { comment.reload }.not_to raise_exception
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }
          authorized_roles = %w[superadmin board legal policy_and_abuse support]

          context "with no role" do
            it "doesn't destroy comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              delete :destroy, params: { id: comment.id }

              it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
              expect { comment.reload }.not_to raise_exception
            end
          end

          (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
            context "with role #{admin_role}" do
              it "doesn't destroy comment and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                delete :destroy, params: { id: comment.id }

                it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
                expect { comment.reload }.not_to raise_exception
              end
            end
          end

          authorized_roles.each do |admin_role|
            context "with the #{admin_role} role" do
              it "destroys comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                delete :destroy, params: { id: comment.id }

                expect(flash[:comment_notice]).to eq("Comment deleted.")
                it_redirects_to_simple(comments_path(tag_id: comment.ultimate_parent, anchor: :comments))
                expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
              end
            end
          end
        end

        context "when logged in as a user" do
          context "when user does not have tag wrangler role" do
            context "when user does not own comment" do
              it "doesn't destroy comment and redirects with error" do
                fake_login
                delete :destroy, params: { id: comment.id }

                it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
                expect { comment.reload }.not_to raise_exception
              end
            end

            context "when user owns comment" do
              it "doesn't destroy comment and redirects with error" do
                fake_login_known_user(comment.pseud.user)
                delete :destroy, params: { id: comment.id }

                it_redirects_to_with_error(user_path(comment.pseud.user), "Sorry, you don't have permission to access the page you were trying to reach.")
                expect { comment.reload }.not_to raise_exception
              end
            end
          end

          context "when user has tag wrangler role" do
            let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }
            let(:frozen_wrangler_comment) { create(:comment, :on_tag, iced: true, pseud: tag_wrangler.pseuds.first) }

            context "when user does not own comment" do
              it "doesn't destroy comment and redirects with error" do
                fake_login_known_user(tag_wrangler)
                delete :destroy, params: { id: comment.id }

                it_redirects_to_with_error(comment, "Sorry, you don't have permission to access the page you were trying to reach.")
                expect { comment.reload }.not_to raise_exception
              end
            end

            context "when user owns comment" do
              it "destroys comment and redirects with success message" do
                fake_login_known_user(tag_wrangler)
                delete :destroy, params: { id: frozen_wrangler_comment.id }

                expect(flash[:comment_notice]).to eq("Comment deleted.")
                it_redirects_to_simple(comments_path(tag_id: frozen_wrangler_comment.ultimate_parent, anchor: :comments))
                expect { frozen_wrangler_comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment, iced: true) }

        context "when logged out" do
          it "doesn't destroy comment and redirects with error" do
            delete :destroy, params: { id: comment.id }

            it_redirects_to_with_error(comment, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
            expect { comment.reload }.not_to raise_exception
          end

          context "when Work is restricted" do
            context "when commentable is a comment" do
              let(:work) { comment.ultimate_parent }

              before { work.update!(restricted: true) }

              it "redirects to the login page" do
                delete :destroy, params: { id: comment.id }
                it_redirects_to(new_user_session_path(restricted_commenting: true, return_to: request.fullpath))
              end
            end
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }
          authorized_roles = %w[superadmin board legal policy_and_abuse support]

          context "with no role" do
            it "doesn't destroy comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              delete :destroy, params: { id: comment.id }

              it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
              expect { comment.reload }.not_to raise_exception
            end
          end

          (Admin::VALID_ROLES - authorized_roles).each do |admin_role|
            context "with role #{admin_role}" do
              it "doesn't destroy comment and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                delete :destroy, params: { id: comment.id }

                it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
                expect { comment.reload }.not_to raise_exception
              end
            end
          end

          authorized_roles.each do |admin_role|
            context "with the #{admin_role} role" do
              it "destroys comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                delete :destroy, params: { id: comment.id }

                expect(flash[:comment_notice]).to eq("Comment deleted.")
                it_redirects_to_simple(work_path(comment.ultimate_parent, show_comments: true, anchor: :comments))
                expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
              end
            end
          end
        end

        context "when logged in as a user" do
          context "when user does not own comment" do
            it "doesn't destroy comment and redirects with error" do
              fake_login
              delete :destroy, params: { id: comment.id }

              it_redirects_to_with_error(comment, "Sorry, you don't have permission to access the page you were trying to reach.")
              expect { comment.reload }.not_to raise_exception
            end
          end

          context "when user owns comment" do
            it "destroys comment and redirects with success message" do
              fake_login_known_user(comment.pseud.user)
              delete :destroy, params: { id: comment.id }

              expect(flash[:comment_notice]).to eq("Comment deleted.")
              it_redirects_to_simple(work_path(comment.ultimate_parent, show_comments: true, anchor: :comments))
              expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
            end
          end

          context "when user owns work" do
            it "destroys comment and redirects with success message" do
              fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
              delete :destroy, params: { id: comment.id }

              expect(flash[:comment_notice]).to eq("Comment deleted.")
              it_redirects_to_simple(work_path(comment.ultimate_parent, show_comments: true, anchor: :comments))
              expect { comment.reload }.to raise_exception(ActiveRecord::RecordNotFound)
            end
          end
        end
      end
    end
  end

  describe "GET #show" do
    it "redirects to root path if logged in user does not have permission to access comment" do
      fake_login
      get :show, params: { id: unreviewed_comment.id }
      it_redirects_to_with_error(root_path, "Sorry, that comment is currently in moderation.")
    end

    it "assigns page subtitle using work title format" do
      work = comment.ultimate_parent
      get :show, params: { id: comment.id }
      expect(assigns[:page_subtitle]).to eq("Comment #{comment.id} on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
    end

    it "assigns page subtitle using work title format for reply comment" do
      work = comment.ultimate_parent
      reply = create(:comment, commentable: comment)
      get :show, params: { id: reply.id }
      expect(assigns[:page_subtitle]).to eq("Comment #{reply.id} on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
    end

    it "assigns page subtitle using admin post title" do
      admin_post = create(:admin_post)
      comment = create(:comment, commentable: admin_post)
      get :show, params: { id: comment.id }
      expect(assigns[:page_subtitle]).to eq("Comment #{comment.id} on #{admin_post.title}")
    end

    it "assigns page subtitle using tag name" do
      fake_login_admin(create(:admin))
      tag = create(:canonical_fandom)
      comment = create(:comment, commentable: tag)
      get :show, params: { id: comment.id }
      expect(assigns[:page_subtitle]).to eq("Comment #{comment.id} on #{tag.name}")
    end
  end

  describe "GET #index" do
    it "redirects to 404 when not logged in as admin" do
      get :index

      it_redirects_to_simple("/404")
    end

    it "redirects to 404 when logged in as admin" do
      fake_login_admin(create(:admin))

      get :index

      it_redirects_to_simple("/404")
    end

    context "denies access for work that isn't visible to user" do
      subject { get :index, params: { work_id: work } }
      let(:success) { expect(response).to render_template("index") }
      let(:success_admin) { success }

      include_examples "denies access for work that isn't visible to user"
    end

    context "denies access for restricted work to guest" do
      let(:work) { create(:work, restricted: true) }

      it "redirects with an error" do
        get :index, params: { work_id: work }
        it_redirects_to(new_user_session_path(restricted_commenting: true, return_to: request.fullpath))
      end
    end

    it "assigns page subtitle using work title format" do
      work = create(:work)
      get :index, params: { work_id: work }
      expect(assigns[:page_subtitle]).to eq("Comments on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
    end

    it "assigns page subtitle using work title format for comment replies on work" do
      work = create(:work)
      comment = create(:comment, commentable: work)
      get :index, params: { comment_id: comment }
      expect(assigns[:page_subtitle]).to eq("Comments on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
    end

    it "assigns page subtitle using admin post title" do
      admin_post = create(:admin_post)
      get :index, params: { admin_post_id: admin_post }
      expect(assigns[:page_subtitle]).to eq("Comments on #{admin_post.title}")
    end

    it "assigns page subtitle using tag name" do
      fake_login_admin(create(:admin))
      tag = create(:canonical_fandom)
      get :index, params: { tag_id: tag }
      expect(assigns[:page_subtitle]).to eq("Comments on #{tag.name}")
    end
  end
end
