require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }
  let(:unreviewed_comment) { create(:comment, :unreviewed) }

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "GET #unreviewed" do
    context "when the commentable is a chapter of a work" do
      let(:user) { create(:user) }
      let(:work) { create(:work, authors: [user.default_pseud], moderated_commenting_enabled: true) }

      it "redirects logged out users to login path with an error" do
        get :unreviewed, params: { work_id: work.id }
        it_redirects_to_with_error(new_user_session_path(return_to: unreviewed_work_comments_path(work)), "Sorry, you don't have permission to see those unreviewed comments.")
      end

      it "redirects to root path with an error when logged in user does not own the commentable" do
        fake_login
        get :unreviewed, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to see those unreviewed comments.")
      end

      it "renders the :unreviewed template for a user who owns the work" do
        fake_login_known_user(user)
        get :unreviewed, params: { work_id: work.id }
        expect(response).to render_template("unreviewed")
      end

      it "renders the :unreviewed template for an admin" do
        fake_login_admin(create(:admin))
        get :unreviewed, params: { work_id: work.id }
        expect(response).to render_template("unreviewed")
      end

      it "assigns page subtitle using work title format" do
        fake_login_known_user(user)
        get :unreviewed, params: { work_id: work.id }
        expect(assigns[:page_subtitle]).to eq("Unreviewed Comments on #{work.title} - #{work.pseuds.first.byline} - #{work.fandoms.first.name}")
      end
    end

    context "when the commentable is an admin post" do
      let(:admin_post) { create(:admin_post, moderated_commenting_enabled: true) }

      it "redirects logged out users to login path with an error" do
        get :unreviewed, params: { admin_post_id: admin_post.id }
        it_redirects_to_with_error(new_user_session_path(return_to: unreviewed_admin_post_comments_path(admin_post)), "Sorry, you don't have permission to see those unreviewed comments.")
      end

      it "redirects logged in users to root path with an error" do
        fake_login
        get :unreviewed, params: { admin_post_id: admin_post.id }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to see those unreviewed comments.")
      end

      it "renders the :unreviewed template for an admin" do
        fake_login_admin(create(:admin))
        get :unreviewed, params: { admin_post_id: admin_post.id }
        expect(response).to render_template("unreviewed")
      end

      it "assigns page subtitle using admin post title" do
        fake_login_admin(create(:admin))
        get :unreviewed, params: { admin_post_id: admin_post.id }
        expect(assigns[:page_subtitle]).to eq("Unreviewed Comments on #{admin_post.title}")
      end
    end
  end
  
  describe "PUT #review_all" do
    context "when commentable is a chapter on a work" do
      let(:work) { unreviewed_comment.commentable.work }
      let(:user) { work.users.first }

      it "redirects logged out user to referrer with error and does not mark comment reviewed" do
        put :review_all, params: { work_id: work.id }
        it_redirects_to_with_error("/where_i_came_from", "What did you want to review comments on?")
        expect(unreviewed_comment.reload.unreviewed).to be_truthy
      end

      context "when logged in" do
        context "when current user does not own the work" do
          it "redirects to referrer with error and does not mark comment reviewed" do
            fake_login
            put :review_all, params: { work_id: work.id }
            it_redirects_to_with_error("/where_i_came_from", "What did you want to review comments on?")
            expect(unreviewed_comment.reload.unreviewed).to be_truthy
          end
        end

        context "when current user owns the work" do
          it "redirects to commentable with notice and marks comment reviewed" do
            fake_login_known_user(user)
            put :review_all, params: { work_id: work.id }
            it_redirects_to_with_notice(work_path(work), "All moderated comments approved.")
            expect(unreviewed_comment.reload.unreviewed).to be_falsey
          end
        end
      end

      it "redirects logged in admin to root path with error and does not mark comment reviewed" do
        fake_login_admin(create(:admin))
        put :review_all, params: { work_id: work.id }
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
        expect(unreviewed_comment.reload.unreviewed).to be_truthy
      end
    end

    context "when commentable is an admin post" do
      let(:admin_post) { create(:admin_post, moderated_commenting_enabled: true) }
      let!(:comment1) { create(:comment, :unreviewed, commentable: admin_post) }
      let!(:comment2) { create(:comment, :unreviewed, commentable: admin_post) }

      it "redirects logged out user to referrer with error and does not mark comments reviewed" do
        put :review_all, params: { admin_post_id: admin_post.id }
        it_redirects_to_with_error("/where_i_came_from", "What did you want to review comments on?")
        expect(comment1.reload.unreviewed).to be_truthy
        expect(comment2.reload.unreviewed).to be_truthy
      end

      it "redirects logged in user to referrer with error and does not mark comments reviewed" do
        fake_login
        put :review_all, params: { admin_post_id: admin_post.id }
        it_redirects_to_with_error("/where_i_came_from", "What did you want to review comments on?")
        expect(comment1.reload.unreviewed).to be_truthy
        expect(comment2.reload.unreviewed).to be_truthy
      end

      it "redirects logged in admin to commentable with notice and marks comments reviewed" do
        fake_login_admin(create(:admin))
        put :review_all, params: { admin_post_id: admin_post.id }
        it_redirects_to_with_notice(admin_post_path(admin_post), "All moderated comments approved.")
        expect(comment1.reload.unreviewed).to be_falsey
        expect(comment2.reload.unreviewed).to be_falsey
      end
    end
  end

  describe "PUT #review" do
    context "when commentable is a chapter on a work" do
      let!(:user) { create(:user) }
      let!(:work) { create(:work, authors: [user.default_pseud], moderated_commenting_enabled: true) }
      let(:comment) { create(:comment, :unreviewed, commentable: work.first_chapter) }
      let!(:inbox_comment) { create(:inbox_comment, feedback_comment: comment, user: user, read: false) }

      context "when logged out" do
        it "redirects to 404, does not mark comment reviewed, and does not mark work owner's inbox comment read" do
          put :review, params: { id: comment.id }
          it_redirects_to_simple("/404")
          expect(comment.reload.unreviewed).to be_truthy
          expect(inbox_comment.reload.read).to be_falsey
        end
      end

      context "when logged in" do
        context "when user owns the work" do
          before do
            fake_login_known_user(user)
          end

          context "with approved_from params set to inbox" do
            it "redirects to user inbox path with success message, marks comment reviewed, and marks inbox comment read" do
              put :review, params: { id: comment.id, approved_from: "inbox" }
              it_redirects_to_with_notice(user_inbox_path(user), "Comment approved.")
              expect(comment.reload.unreviewed).to be_falsey
              expect(inbox_comment.reload.read).to be_truthy
            end
          end

          context "with approved_from params set to inbox with filters" do
            it "redirects to filtered user inbox path with success message, marks comment reviewed, and marks inbox comment read" do
              put :review, params: { id: comment.id, approved_from: "inbox", filters: { date: "asc" } }
              expect(response).to redirect_to(user_inbox_path(user, filters: { date: "asc" }))
              expect(flash[:notice]).to eq "Comment approved."
              expect(comment.reload.unreviewed).to be_falsey
              expect(inbox_comment.reload.read).to be_truthy
            end
          end

          context "with approved_from params set to home" do
            it "redirects to root path with success message, marks comment reviewed, and marks inbox comment read" do
              put :review, params: { id: comment.id, approved_from: "home" }
              it_redirects_to_with_notice(root_path, "Comment approved.")
              expect(comment.reload.unreviewed).to be_falsey
              expect(inbox_comment.reload.read).to be_truthy
            end
          end

          context "without approved_from params" do
            it "redirects to unreviewed comments with notice, marks comment reviewed, and marks inbox comment read" do
              put :review, params: { id: comment.id }
              it_redirects_to_with_notice(unreviewed_work_comments_path(work), "Comment approved.")
              expect(comment.reload.unreviewed).to be_falsey
              expect(inbox_comment.reload.read).to be_truthy
            end
          end
        end

        context "when user does not own the work" do
          it "redirects to 404, does not mark comment reviewed, and does not mark work owner's inbox comment read" do
            fake_login
            put :review, params: { id: comment.id }
            it_redirects_to_simple("/404")
            expect(comment.reload.unreviewed).to be_truthy
            expect(inbox_comment.reload.read).to be_falsey
          end
        end
      end

      context "when logged in as admin" do
        it "redirects to rooth path with error, does not mark comment reviewed, and does not mark work owner's inbox comment read" do
          fake_login_admin(create(:admin))
          put :review, params: { id: comment.id }
          it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
          expect(comment.reload.unreviewed).to be_truthy
          expect(inbox_comment.reload.read).to be_falsey
        end
      end
    end

    context "when commentable is an admin post" do
      let(:admin_post) { create(:admin_post, moderated_commenting_enabled: true) }
      let(:comment) { create(:comment, :unreviewed, commentable: admin_post) }

      context "when logged out" do
        it "redirects to 404 and does not mark comment reviewed" do
          put :review, params: { id: comment.id }
          it_redirects_to_simple("/404")
          expect(comment.reload.unreviewed).to be_truthy
        end
      end

      context "when logged in" do
        it "redirects to 404 and does not mark comment reviewed" do
          fake_login
          put :review, params: { id: comment.id }
          it_redirects_to_simple("/404")
          expect(comment.reload.unreviewed).to be_truthy
        end
      end

      context "when logged in as admin" do
        it "redirects to unreviewed comments with notice and marks comment reviewed" do
          fake_login_admin(create(:admin))
          put :review, params: { id: comment.id }
          it_redirects_to_with_notice(unreviewed_admin_post_comments_path(admin_post), "Comment approved.")
          expect(comment.reload.unreviewed).to be_falsey
        end
      end
    end
  end

  describe "PUT #reject" do
    shared_examples "a comment that can only be rejected by an authorized admin" do
      it "doesn't mark the comment as spam and redirects with an error" do
        put :reject, params: { id: comment.id }
        comment.reload
        expect(comment.approved).to be_truthy
        expect(comment.spam).to be_falsey
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "a comment the logged-in user can't reject" do
      it "doesn't mark the comment as spam and redirects with an error" do
        put :reject, params: { id: comment.id }
        comment.reload
        expect(comment.approved).to be_truthy
        expect(comment.spam).to be_falsey
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to moderate that comment.")
      end
    end

    shared_examples "marking a comment spam" do
      context "when ultimate parent is an AdminPost" do
        let(:admin_post) { create(:admin_post) }
        authorized_roles = %w[superadmin board board_assistants_team communications elections policy_and_abuse support]
        unauthorized_roles = Admin::VALID_ROLES - authorized_roles

        before do
          comment.commentable = admin_post
          comment.parent = admin_post
          comment.save
          comment.reload
        end

        authorized_roles.each do |role|
          context "when logged-in as admin with the role #{role}" do
            before { fake_login_admin(create(:admin, roles: [role])) }

            it "marks the comment as spam" do
              put :reject, params: { id: comment.id }
              expect(flash[:error]).to be_nil
              expect(response).to redirect_to(admin_post_path(comment.ultimate_parent,
                                                              show_comments: true,
                                                              anchor: "comments"))
              comment.reload
              expect(comment.approved).to be_falsey
              expect(comment.spam).to be_truthy
            end
          end
        end

        unauthorized_roles.each do |role|
          context "when logged-in as admin with the role #{role}" do
            before { fake_login_admin(create(:admin, roles: [role])) }

            it_behaves_like "a comment that can only be rejected by an authorized admin"
          end

          context "when logged-in as admin with no role" do
            before { fake_login_admin(create(:admin, roles: [role])) }

            it_behaves_like "a comment that can only be rejected by an authorized admin"
          end
        end
      end

      context "when ultimate parent is a Work" do
        context "when logged-in as admin" do
          authorized_roles = %w[superadmin board policy_and_abuse support]
          unauthorized_roles = Admin::VALID_ROLES - authorized_roles

          authorized_roles.each do |role|
            context "with the role #{role}" do
              before { fake_login_admin(create(:admin, roles: [role])) }

              it "marks the comment as spam" do
                put :reject, params: { id: comment.id }
                expect(flash[:error]).to be_nil
                expect(response).to redirect_to(work_path(comment.ultimate_parent,
                                                          show_comments: true,
                                                          anchor: "comments"))
                comment.reload
                expect(comment.approved).to be_falsey
                expect(comment.spam).to be_truthy
              end
            end
          end

          unauthorized_roles.each do |role|
            context "with the role #{role}" do
              before { fake_login_admin(create(:admin, roles: [role])) }

              it_behaves_like "a comment that can only be rejected by an authorized admin"
            end
          end

          context "with no role" do
            before { fake_login_admin(create(:admin)) }

            it_behaves_like "a comment that can only be rejected by an authorized admin"
          end
        end

        context "when logged-in as the work's creator" do
          before { fake_login_known_user(comment.ultimate_parent.users.first) }

          it "marks the comment as spam" do
            put :reject, params: { id: comment.id }
            expect(flash[:error]).to be_nil
            expect(response).to redirect_to(work_path(comment.ultimate_parent,
                                                      show_comments: true,
                                                      anchor: "comments"))
            comment.reload
            expect(comment.approved).to be_falsey
            expect(comment.spam).to be_truthy
          end
        end
      end

      context "when logged-in as the comment writer" do
        before { fake_login_known_user(comment.pseud.user) }

        it_behaves_like "a comment the logged-in user can't reject"
      end

      context "when logged-in as a random user" do
        before { fake_login }

        it_behaves_like "a comment the logged-in user can't reject"
      end

      context "when not logged-in" do
        before { fake_logout }

        it "doesn't mark the comment as spam and redirects with an error" do
          put :reject, params: { id: comment.id }
          comment.reload
          expect(comment.approved).to be_truthy
          expect(comment.spam).to be_falsey
          it_redirects_to_with_error(
            new_user_session_path(return_to: comment_path(comment)),
            "Sorry, you don't have permission to moderate that comment."
          )
        end
      end
    end

    it_behaves_like "marking a comment spam"

    context "when comment is frozen" do
      let(:comment) { create(:comment, iced: true) }

      it_behaves_like "marking a comment spam"
    end
  end

  describe "PUT #approve" do
    before { comment.update_columns(approved: false, spam: true) }

    shared_examples "a comment that can only be approved by an authorized admin" do
      it "leaves the comment marked as spam and redirects with an error" do
        put :approve, params: { id: comment.id }
        comment.reload
        expect(comment.approved).to be_falsey
        expect(comment.spam).to be_truthy
        it_redirects_to_with_error(root_path, "Sorry, only an authorized admin can access the page you were trying to reach.")
      end
    end

    shared_examples "a comment the logged-in user can't approve" do
      it "doesn't mark the comment as spam and redirects with an error" do
        put :approve, params: { id: comment.id }
        comment.reload
        expect(comment.approved).to be_falsey
        expect(comment.spam).to be_truthy
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to moderate that comment.")
      end
    end

    context "when ultimate parent is an AdminPost" do
      let(:admin) { create(:admin) }
      let(:comment) { create(:comment, :on_admin_post) }
      authorized_roles = %w[superadmin board board_assistants_team communications elections policy_and_abuse support]
      unauthorized_roles = Admin::VALID_ROLES - authorized_roles

      authorized_roles.each do |role|
        context "when logged-in as admin with the role #{role}" do
          it "marks the comment as not spam" do
            fake_login_admin(create(:admin, roles: [role]))
            put :approve, params: { id: comment.id }
            expect(flash[:error]).to be_nil
            expect(response).to redirect_to(admin_post_path(comment.ultimate_parent,
                                                            show_comments: true,
                                                            anchor: "comments"))
            comment.reload
            expect(comment.approved).to be_truthy
            expect(comment.spam).to be_falsey
          end
        end
      end

      unauthorized_roles.each do |role|
        context "when logged-in as admin with the role #{role}" do
          before { fake_login_admin(create(:admin, roles: [role])) }

          it_behaves_like "a comment that can only be approved by an authorized admin"
        end
      end
    end

    context "when ultimate parent is a Work" do
      let(:admin) { create(:admin) }
      authorized_roles = %w[superadmin board policy_and_abuse support]
      unauthorized_roles = Admin::VALID_ROLES - authorized_roles

      authorized_roles.each do |role|
        context "when logged-in as admin with the role #{role}" do
          before { fake_login_admin(create(:admin, roles: [role])) }

          it "marks the comment as not spam" do
            put :approve, params: { id: comment.id }
            expect(flash[:error]).to be_nil
            expect(response).to redirect_to(work_path(comment.ultimate_parent,
                                                      show_comments: true,
                                                      anchor: "comments"))
            comment.reload
            expect(comment.approved).to be_truthy
            expect(comment.spam).to be_falsey
          end
        end
      end

      unauthorized_roles.each do |role|
        context "when logged-in as admin with the role #{role}" do
          before { fake_login_admin(create(:admin, roles: [role])) }

          it_behaves_like "a comment that can only be approved by an authorized admin"
        end
      end

      context "when logged-in as admin with no role" do
        before { fake_login_admin(create(:admin)) }

        it_behaves_like "a comment that can only be approved by an authorized admin"
      end

      context "when logged-in as the work's creator" do
        before { fake_login_known_user(comment.ultimate_parent.users.first) }

        it_behaves_like "a comment that can only be approved by an authorized admin"
      end
    end

    context "when logged-in as the comment writer" do
      before { fake_login_known_user(comment.pseud.user) }

      it_behaves_like "a comment the logged-in user can't approve"
    end

    context "when logged-in as a random user" do
      before { fake_login }

      it_behaves_like "a comment the logged-in user can't approve"
    end

    context "when not logged-in" do
      before { fake_logout }

      it "leaves the comment marked as spam and redirects with an error" do
        put :approve, params: { id: comment.id }
        comment.reload
        expect(comment.approved).to be_falsey
        expect(comment.spam).to be_truthy
        it_redirects_to_with_error(
          new_user_session_path(return_to: comment_path(comment)),
          "Sorry, you don't have permission to moderate that comment."
        )
      end
    end
  end
end
  