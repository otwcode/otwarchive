require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:comment) { create(:comment) }
  let(:unreviewed_comment) { create(:comment, :unreviewed) }

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "PUT #freeze" do
    context "when comment is not frozen" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post) }

        context "when logged out" do
          it "doesn't freeze comment and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "freezes comment and redirects with success message" do
            fake_login_admin(admin)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_comment_notice(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully frozen!"
            )
          end

          context "when comment is a guest reply to user who turns off guest replies afterwards" do
            let(:reply) do
              reply = create(:comment, :by_guest, commentable: comment)
              comment.user.preference.update!(guest_replies_off: true)
              reply
            end

            it "freezes reply and redirects with success message" do
              fake_login_admin(admin)
              put :freeze, params: { id: reply.id }

              expect(reply.reload.iced).to be_truthy
              it_redirects_to_with_comment_notice(
                admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                "Comment thread successfully frozen!"
              )
            end
          end
        end

        context "when logged in as a user" do
          it "doesn't freeze comment and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag) }

        context "when logged out" do
          it "doesn't freeze comment and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't freeze comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :freeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
            end
          end

          %w[superadmin tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "freezes comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :freeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_truthy
                it_redirects_to_with_comment_notice(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Comment thread successfully frozen!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't freeze comment and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "doesn't freeze comment and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment) }

        context "when logged out" do
          it "doesn't freeze comment and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't freeze comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :freeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
            end
          end

          %w[superadmin policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "freezes comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :freeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_truthy
                it_redirects_to_with_comment_notice(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Comment thread successfully frozen!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't freeze comment and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "freezes the comment and redirects with success message" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_comment_notice(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully frozen!"
            )
          end
        end
      end

      context "when comment is the start of a thread" do
        let!(:comment) { create(:comment) }
        let!(:child1) { create(:comment, commentable: comment) }
        let!(:grandchild) { create(:comment, commentable: child1) }
        let!(:child2) { create(:comment, commentable: comment) }

        it "freezes entire thread and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          [comment, child1, child2, grandchild].each do |comment|
            expect(comment.reload.iced).to be_truthy
          end
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully frozen!"
          )
        end
      end

      context "when comment is the middle of a thread" do
        let!(:parent) { create(:comment) }
        let!(:comment) { create(:comment, commentable: parent) }
        let!(:child) { create(:comment, commentable: comment) }
        let!(:sibling) { create(:comment, commentable: parent) }

        it "freezes the comment and its child, but not its parent or sibling, and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          expect(comment.reload.iced).to be_truthy
          expect(child.reload.iced).to be_truthy
          expect(parent.reload.iced).to be_falsey
          expect(sibling.reload.iced).to be_falsey
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully frozen!"
          )
        end
      end

      context "when comment is the end of a thread" do
        let!(:parent) { create(:comment) }
        let!(:child1) { create(:comment, commentable: parent) }
        let!(:child2) { create(:comment, commentable: parent) }
        let!(:comment) { create(:comment, commentable: child1) }

        it "freezes the comment, but no other comments in the thread, and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          expect(parent.reload.iced).to be_falsey
          expect(child1.reload.iced).to be_falsey
          expect(child2.reload.iced).to be_falsey
          expect(comment.reload.iced).to be_truthy
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully frozen!"
          )
        end
      end

      context "when comment is spam" do
        let(:comment) { create(:comment) }

        before { comment.update_attribute(:approved, false) }

        it "freezes the comment and redirects with success message without changing the approved status" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          expect(comment.reload.iced).to be_truthy
          expect(comment.reload.approved).to be_falsey
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully frozen!"
          )
        end
      end

      context "when comment is not saved" do
        let!(:comment) { create(:comment) }

        before do
          allow_any_instance_of(Comment).to receive(:save).and_return(false)
        end

        it "redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be frozen."
          )
        end
      end
    end

    context "when comment is frozen" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post, iced: true) }

        context "when logged out" do
          it "leaves comment frozen and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "leaves comment frozen and redirects with error" do
            fake_login_admin(admin)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_comment_error(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment thread could not be frozen."
            )
          end
        end

        context "when logged in as a user" do
          it "leaves comment frozen and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag, iced: true) }

        context "when logged out" do
          it "leaves comment frozen and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment frozen and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :freeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
            end
          end

          %w[superadmin tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment frozen and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :freeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_truthy
                it_redirects_to_with_comment_error(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Sorry, that comment thread could not be frozen."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment frozen and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "leaves comment frozen and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment, iced: true) }

        context "when logged out" do
          it "leaves comment frozen and redirects with error" do
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment frozen and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :freeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
            end
          end

          %w[superadmin policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment frozen and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :freeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_truthy
                it_redirects_to_with_comment_error(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Sorry, that comment thread could not be frozen."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment frozen and redirects with error" do
            fake_login
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to freeze that comment thread.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "leaves comment frozen and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :freeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_comment_error(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment thread could not be frozen."
            )
          end
        end
      end

      context "when comment is the start of a thread" do
        let!(:comment) { create(:comment, iced: true) }
        let!(:child1) { create(:comment, commentable: comment, iced: true) }
        let!(:grandchild) { create(:comment, commentable: child1, iced: true) }
        let!(:child2) { create(:comment, commentable: comment, iced: true) }

        it "leaves thread frozen and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          [comment, child1, child2, grandchild].each do |comment|
            expect(comment.reload.iced).to be_truthy
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be frozen."
          )
        end
      end

      context "when comment is the middle of a thread" do
        let!(:parent) { create(:comment, iced: true) }
        let!(:comment) { create(:comment, commentable: parent, iced: true) }
        let!(:child) { create(:comment, commentable: comment, iced: true) }
        let!(:sibling) { create(:comment, commentable: parent, iced: true) }

        it "leaves the comment and its child frozen, as well as its parent and sibling, and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          [comment, child, parent, sibling].each do |comment|
            expect(comment.reload.iced).to be_truthy
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be frozen."
          )
        end
      end

      context "when comment is the end of a thread" do
        let!(:parent) { create(:comment, iced: true) }
        let!(:child1) { create(:comment, commentable: parent, iced: true) }
        let!(:child2) { create(:comment, commentable: parent, iced: true) }
        let!(:comment) { create(:comment, commentable: child1, iced: true) }

        it "leaves the comment frozen, along with any other comments in the thread, and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          [comment, parent, child1, child2].each do |comment|
            expect(comment.reload.iced).to be_truthy
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be frozen."
          )
        end
      end

      context "when comment is not saved" do
        let!(:comment) { create(:comment, iced: true) }

        before do
          allow_any_instance_of(Comment).to receive(:save).and_return(false)
        end

        it "redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :freeze, params: { id: comment.id }

          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be frozen."
          )
        end
      end
    end
  end

  describe "PUT #unfreeze" do
    context "when comment is not frozen" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post) }

        context "when logged out" do
          it "leaves comment unfrozen and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "leaves comment unfrozen and redirects with error" do
            fake_login_admin(admin)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_comment_error(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment thread could not be unfrozen."
            )
          end
        end

        context "when logged in as a user" do
          it "leaves comment unfrozen and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag) }

        context "when logged out" do
          it "leaves comment unfrozen and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaces comment unfrozen and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unfreeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
            end
          end

          %w[superadmin tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment unfrozen and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unfreeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_falsey
                it_redirects_to_with_comment_error(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Sorry, that comment thread could not be unfrozen."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment unfrozen and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "leaves comment unfrozen and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment) }

        context "when logged out" do
          it "leaves comment unfrozen and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment unfrozen and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unfreeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
            end
          end

          %w[superadmin policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment unfrozen and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unfreeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_falsey
                it_redirects_to_with_comment_error(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Sorry, that comment thread could not be unfrozen."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment unfrozen and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "leaves comment unfrozen and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_comment_error(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment thread could not be unfrozen."
            )
          end
        end
      end

      context "when comment is the start of a thread" do
        let!(:comment) { create(:comment) }
        let!(:child1) { create(:comment, commentable: comment) }
        let!(:grandchild) { create(:comment, commentable: child1) }
        let!(:child2) { create(:comment, commentable: comment) }

        it "leaves entire thread unfrozen and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          [comment, child1, child2, grandchild].each do |comment|
            expect(comment.reload.iced).to be_falsey
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be unfrozen."
          )
        end
      end

      context "when comment is the middle of a thread" do
        let!(:parent) { create(:comment) }
        let!(:comment) { create(:comment, commentable: parent) }
        let!(:child) { create(:comment, commentable: comment) }
        let!(:sibling) { create(:comment, commentable: parent) }

        it "leaves the comment and its child frozen, as well as its parent and sibling, and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          [comment, child, parent, sibling].each do |comment|
            expect(comment.reload.iced).to be_falsey
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be unfrozen."
          )
        end
      end

      context "when comment is the end of a thread" do
        let!(:parent) { create(:comment) }
        let!(:child1) { create(:comment, commentable: parent) }
        let!(:child2) { create(:comment, commentable: parent) }
        let!(:comment) { create(:comment, commentable: child1) }

        it "leaves the comment unfrozen, along with any other comments in the thread, and redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          [comment, parent, child1, child2].each do |comment|
            expect(comment.reload.iced).to be_falsey
          end
          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be unfrozen."
          )
        end
      end

      context "when comment is not saved" do
        let!(:comment) { create(:comment) }

        before do
          allow_any_instance_of(Comment).to receive(:save).and_return(false)
        end

        it "redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be unfrozen."
          )
        end
      end
    end

    context "when comment is frozen" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post, iced: true) }

        context "when logged out" do
          it "doesn't unfreeze comment and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "unfreezes comment and redirects with success message" do
            fake_login_admin(admin)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_comment_notice(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully unfrozen!"
            )
          end
        end

        context "when logged in as a user" do
          it "doesn't unfreeze comment and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag, iced: true) }

        context "when logged out" do
          it "doesn't unfreeze comment and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error(new_user_session_path, "Sorry, you don't have permission to access the page you were trying to reach. Please log in.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't unfreeze comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unfreeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
            end
          end

          %w[superadmin tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "unfreezes comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unfreeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_falsey
                it_redirects_to_with_comment_notice(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Comment thread successfully unfrozen!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't unfreeze comment and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "doesn't unfreeze comment and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment, iced: true) }

        context "when logged out" do
          it "doesn't unfreeze comment and redirects with error" do
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't unfreeze comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unfreeze, params: { id: comment.id }

              expect(comment.reload.iced).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
            end
          end

          %w[superadmin policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "unfreezes comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unfreeze, params: { id: comment.id }

                expect(comment.reload.iced).to be_falsey
                it_redirects_to_with_comment_notice(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Comment thread successfully unfrozen!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't unfreeze comment and redirects with error" do
            fake_login
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unfreeze that comment thread.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "freezes the comment and redirects with success message" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :unfreeze, params: { id: comment.id }

            expect(comment.reload.iced).to be_falsey
            it_redirects_to_with_comment_notice(
              work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment thread successfully unfrozen!"
            )
          end
        end
      end

      context "when comment is the start of a thread" do
        let!(:comment) { create(:comment, iced: true) }
        let!(:child1) { create(:comment, commentable: comment, iced: true) }
        let!(:grandchild) { create(:comment, commentable: child1, iced: true) }
        let!(:child2) { create(:comment, commentable: comment, iced: true) }

        it "unfreezes entire thread and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          [comment, child1, child2, grandchild].each do |comment|
            expect(comment.reload.iced).to be_falsey
          end
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully unfrozen!"
          )
        end
      end

      context "when comment is the middle of a thread" do
        let!(:parent) { create(:comment, iced: true) }
        let!(:comment) { create(:comment, commentable: parent, iced: true) }
        let!(:child) { create(:comment, commentable: comment, iced: true) }
        let!(:sibling) { create(:comment, commentable: parent, iced: true) }

        it "unfreezes the comment and its child, but not its parent or sibling, and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          expect(comment.reload.iced).to be_falsey
          expect(child.reload.iced).to be_falsey
          expect(parent.reload.iced).to be_truthy
          expect(sibling.reload.iced).to be_truthy
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully unfrozen!"
          )
        end
      end

      context "when comment is the end of a thread" do
        let!(:parent) { create(:comment, iced: true) }
        let!(:child1) { create(:comment, commentable: parent, iced: true) }
        let!(:child2) { create(:comment, commentable: parent, iced: true) }
        let!(:comment) { create(:comment, commentable: child1, iced: true) }

        it "unfreezes the comment, but no other comments in the thread, and redirects with success message" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          expect(parent.reload.iced).to be_truthy
          expect(child1.reload.iced).to be_truthy
          expect(child2.reload.iced).to be_truthy
          expect(comment.reload.iced).to be_falsey
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully unfrozen!"
          )
        end
      end

      context "when comment is spam" do
        let(:comment) { create(:comment, iced: true) }

        before { comment.update_attribute(:approved, false) }

        it "unfreezes the comment and redirects with success message without changing the approved status" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          expect(comment.reload.iced).to be_falsey
          expect(comment.reload.approved).to be_falsey
          it_redirects_to_with_comment_notice(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Comment thread successfully unfrozen!"
          )
        end
      end

      context "when comment is not saved" do
        let!(:comment) { create(:comment, iced: true) }

        before do
          allow_any_instance_of(Comment).to receive(:save).and_return(false)
        end

        it "redirects with error" do
          fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
          put :unfreeze, params: { id: comment.id }

          it_redirects_to_with_comment_error(
            work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
            "Sorry, that comment thread could not be unfrozen."
          )
        end
      end
    end
  end
end
