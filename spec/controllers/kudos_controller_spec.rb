# frozen_string_literal: true

require "spec_helper"

describe KudosController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "POST #create" do
    context "when work is public" do
      let(:work) { create(:work) }
      let(:referer) { work_path(work) }
      before { request.headers["HTTP_REFERER"] = referer }

      context "when kudos giver is a guest" do
        context "when kudos are given from work" do
          it "redirects to referer with a notice" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
            it_redirects_to_with_kudos_notice(referer, "Thank you for leaving kudos!")
          end

          it "does not save user on kudos" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
            expect(assigns(:kudo).user).to be_nil
          end
        end

        context "when kudos are given from chapter" do
          it "redirects to referer with a notice" do
            post :create, params: { kudo: { commentable_id: work.first_chapter.id, commentable_type: "Chapter" } }
            it_redirects_to_with_kudos_notice(referer, "Thank you for leaving kudos!")
          end

          it "does not save user on kudos" do
            post :create, params: { kudo: { commentable_id: work.first_chapter.id, commentable_type: "Chapter" } }
            expect(assigns(:kudo).user).to be_nil
          end
        end
      end

      context "when kudos giver is logged in" do
        let(:user) { create(:user) }
        before { fake_login_known_user(user) }

        it "redirects to referer with a notice" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_kudos_notice(referer, "Thank you for leaving kudos!")
        end

        it "saves user on kudos" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          expect(assigns(:kudo).user).to eq(user)
        end

        context "when kudos giver has already left kudos on the work" do
          let!(:old_kudo) { create(:kudo, user: user, commentable: work) }

          it "redirects to referer with an error" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
            # TODO: AO3-5635 Fix this error message.
            it_redirects_to_with_kudos_error(referer, "User ^You have already left kudos here. :)")
          end

          context "when duplicate database inserts happen despite Rails validations" do
            # https://api.rubyonrails.org/v5.1/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of-label-Concurrency+and+integrity
            #
            # We fake this scenario by skipping Rails validations.
            before do
              allow_any_instance_of(Kudo).to receive(:save).and_call_original
              allow_any_instance_of(Kudo).to receive(:save).with(no_args) do |kudo|
                kudo.save(validate: false)
              end
            end

            it "redirects to referer with an error" do
              post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
              it_redirects_to_with_kudos_error(referer, "You have already left kudos here. :)")
            end

            context "with format: :js" do
              it "returns an error in JSON format" do
                post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
                expect(JSON.parse(response.body)["errors"]).to include("ip_address")
              end
            end
          end
        end
      end

      context "when kudos giver is creator of work" do
        before { fake_login_known_user(work.users.first) }

        it "redirects to referer with an error" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          it_redirects_to_with_kudos_error(referer, "You can't leave kudos on your own work.")
        end

        it "does not save kudos" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          expect(assigns(:kudo).new_record?).to be_truthy
        end

        context "with format: :js" do
          it "returns an error in JSON format" do
            post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
            expect(JSON.parse(response.body)["errors"]["cannot_be_author"]).to include("^You can't leave kudos on your own work.")
          end
        end
      end
    end

    context "when work does not exist" do
      it "redirects to referer with an error" do
        referer = root_path
        request.headers["HTTP_REFERER"] = referer
        post :create, params: { kudo: { commentable_id: "333", commentable_type: "Work" } }
        it_redirects_to_with_kudos_error(referer, "We couldn't save your kudos, sorry!")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: "333", commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["no_commentable"]).to include("^What did you want to leave kudos on?")
        end
      end
    end

    context "when work is restricted" do
      let(:work) { create(:work, restricted: true) }

      it "redirects to referer with an error" do
        referer = work_path(work)
        request.headers["HTTP_REFERER"] = referer
        post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        it_redirects_to_with_kudos_error(referer, "You can't leave guest kudos on a restricted work.")
      end

      context "with format: :js" do
        it "returns an error in JSON format" do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["guest_on_restricted"]).to include("^You can't leave guest kudos on a restricted work.")
        end
      end
    end
  end
end
