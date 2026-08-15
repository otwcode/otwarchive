require "spec_helper"

describe CommentsController do
  include LoginMacros
  include RedirectExpectationHelper

  before do
    request.env["HTTP_REFERER"] = "/where_i_came_from"
  end

  describe "PUT #hide" do
    context "when comment is not hidden" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post) }

        context "when logged out" do
          it "doesn't hide comment and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "hides comment and redirects with success message" do
            fake_login_admin(admin)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_comment_notice(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment successfully hidden!"
            )
          end
        end

        context "when logged in as a user" do
          it "doesn't hide comment and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag) }

        context "when logged out" do
          it "doesn't hide comment and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_user_login_with_error
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't hide comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :hide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
            end
          end

          %w[superadmin legal tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "hides comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :hide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_truthy
                it_redirects_to_with_comment_notice(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Comment successfully hidden!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't hide comment and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "doesn't hide comment and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment) }

        context "when logged out" do
          it "doesn't hide comment and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't hide comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :hide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
            end
          end

          %w[superadmin legal policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "hides comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :hide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_truthy
                it_redirects_to_with_comment_notice(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Comment successfully hidden!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't hide comment and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "doesn't hide the comment and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end
    end

    context "when comment is hidden" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post, hidden_by_admin: true) }

        context "when logged out" do
          it "leaves comment hidden and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "leaves comment hidden and redirects with error" do
            fake_login_admin(admin)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_comment_error(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment could not be hidden."
            )
          end
        end

        context "when logged in as a user" do
          it "leaves comment hidden and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag, hidden_by_admin: true) }

        context "when logged out" do
          it "leaves comment hidden and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_user_login_with_error
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment hidden and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :hide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
            end
          end

          %w[superadmin legal tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment hidden and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :hide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_truthy
                it_redirects_to_with_comment_error(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Sorry, that comment could not be hidden."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment hidden and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "leaves comment hidden and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment, hidden_by_admin: true) }

        context "when logged out" do
          it "leaves comment hidden and redirects with error" do
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment hidden and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :hide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
            end
          end

          %w[superadmin legal policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment hidden and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :hide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_truthy
                it_redirects_to_with_comment_error(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Sorry, that comment could not be hidden."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment hidden and redirects with error" do
            fake_login
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "leaves comment hidden and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :hide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to hide that comment.")
          end
        end
      end
    end
  end

  describe "PUT #unhide" do
    context "when comment is hidden" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post, hidden_by_admin: true) }

        context "when logged out" do
          it "doesn't unhide comment and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "unhides comment and redirects with success message" do
            fake_login_admin(admin)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_comment_notice(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Comment successfully unhidden!"
            )
          end
        end

        context "when logged in as a user" do
          it "doesn't unhide comment and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag, hidden_by_admin: true) }

        context "when logged out" do
          it "doesn't unhide comment and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_user_login_with_error
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't unhide comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unhide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
            end
          end

          %w[superadmin legal tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "unhides comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unhide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_falsey
                it_redirects_to_with_comment_notice(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Comment successfully unhidden!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't unhide comment and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "doesn't unhide comment and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment, hidden_by_admin: true) }

        context "when logged out" do
          it "doesn't unhide comment and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "doesn't unhide comment and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unhide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_truthy
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
            end
          end

          %w[superadmin legal policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "unhides comment and redirects with success message" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unhide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_falsey
                it_redirects_to_with_comment_notice(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Comment successfully unhidden!"
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "doesn't unhide comment and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "doesn't unhide the comment and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_truthy
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end
    end

    context "when comment is not hidden" do
      context "when ultimate parent is an AdminPost" do
        let(:comment) { create(:comment, :on_admin_post) }

        context "when logged out" do
          it "leaves comment unhidden and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          it "leaves comment unhidden and redirects with error" do
            fake_login_admin(admin)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_comment_error(
              admin_post_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
              "Sorry, that comment could not be unhidden."
            )
          end
        end

        context "when logged in as a user" do
          it "leaves comment unhidden and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end

      context "when ultimate parent is a Tag" do
        let(:comment) { create(:comment, :on_tag) }

        context "when logged out" do
          it "leaves comment unhidden and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_user_login_with_error
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment unhidden and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unhide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
            end
          end

          %w[superadmin legal tag_wrangling].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment unhidden and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unhide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_falsey
                it_redirects_to_with_comment_error(
                  comments_path(tag_id: comment.ultimate_parent, anchor: :comments),
                  "Sorry, that comment could not be unhidden."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment unhidden and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error(user_path(controller.current_user), "Sorry, you don't have permission to access the page you were trying to reach.")
          end
        end

        context "when logged in as a user with the tag wrangling role" do
          let(:tag_wrangler) { create(:user, roles: [Role.new(name: "tag_wrangler")]) }

          it "leaves comment unhidden and redirects with error" do
            fake_login_known_user(tag_wrangler)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end

      context "when ultimate parent is a Work" do
        let(:comment) { create(:comment) }

        context "when logged out" do
          it "leaves comment unhidden and redirects with error" do
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as an admin" do
          let(:admin) { create(:admin) }

          context "with no role" do
            it "leaves comment unhidden and redirects with error" do
              admin.update!(roles: [])
              fake_login_admin(admin)
              put :unhide, params: { id: comment.id }

              expect(comment.reload.hidden_by_admin?).to be_falsey
              it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
            end
          end

          %w[superadmin legal policy_and_abuse].each do |admin_role|
            context "with the #{admin_role} role" do
              it "leaves comment unhidden and redirects with error" do
                admin.update!(roles: [admin_role])
                fake_login_admin(admin)
                put :unhide, params: { id: comment.id }

                expect(comment.reload.hidden_by_admin?).to be_falsey
                it_redirects_to_with_comment_error(
                  work_path(comment.ultimate_parent, show_comments: true, anchor: :comments),
                  "Sorry, that comment could not be unhidden."
                )
              end
            end
          end
        end

        context "when logged in as a random user" do
          it "leaves comment unhidden and redirects with error" do
            fake_login
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end

        context "when logged in as a user who owns the work" do
          it "leaves comment unhidden and redirects with error" do
            fake_login_known_user(comment.ultimate_parent.pseuds.first.user)
            put :unhide, params: { id: comment.id }

            expect(comment.reload.hidden_by_admin?).to be_falsey
            it_redirects_to_with_error("/where_i_came_from", "Sorry, you don't have permission to unhide that comment.")
          end
        end
      end
    end
  end
end
