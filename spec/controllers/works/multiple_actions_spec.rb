# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:multiple_works_user) { create(:user) }
  let(:banned_user) { create(:user, banned: true) }
  let(:suspended_user) { create(:user, suspended: true, suspended_until: 1.week.from_now) }

  describe "show_multiple" do
    context "when logged in as a user" do
      it "shows Edit Multiple Works page" do
        fake_login_known_user(multiple_works_user)
        get :show_multiple, params: { user_id: multiple_works_user.id }
        expect(response).to render_template("show_multiple")
      end
    end

    context "when logged in as a banned user" do
      it "shows Edit Multiple Works page" do
        fake_login_known_user(banned_user)
        get :show_multiple, params: { user_id: banned_user.id }
        expect(response).to render_template("show_multiple")
      end
    end

    context "when logged in as a suspended user" do
      it "errors and redirects to user page" do
        fake_login_known_user(suspended_user)
        get :show_multiple, params: { user_id: suspended_user.id }
        it_redirects_to_simple(user_path(suspended_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end
  end

  describe "edit_multiple" do
    let!(:work1) { create(:work, authors: [multiple_works_user.default_pseud]) }
    let!(:work2) { create(:work, authors: [multiple_works_user.default_pseud]) }
    let(:work_ids) { [work1.id, work2.id] }

    before do
      fake_login_known_user(multiple_works_user)
    end

    context "when logged in as a user" do
      it "redirects to the orphan path when the Orphan button was clicked" do
        post :edit_multiple, params: { id: work1.id, work_ids: work_ids, commit: "Orphan" }

        it_redirects_to new_orphan_path(work_ids: work_ids)
      end
    end

    context "when logged in as a banned user" do
      it "redirects to the orphan path when the Orphan button was clicked" do
        multiple_works_user.update!(banned: true)
        post :edit_multiple, params: { id: work1.id, work_ids: work_ids, commit: "Orphan" }

        it_redirects_to new_orphan_path(work_ids: work_ids)
      end
    end

    context "when logged in as a suspended user" do
      it "errors and redirects to user page" do
        multiple_works_user.update!(suspended: true, suspended_until: 1.week.from_now)
        post :edit_multiple, params: { id: work1.id, work_ids: work_ids, commit: "Orphan" }

        it_redirects_to_simple(user_path(multiple_works_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end
  end

  describe "confirm_delete_multiple" do
    let!(:work1) { create(:work, authors: [multiple_works_user.default_pseud]) }
    let!(:work2) { create(:work, authors: [multiple_works_user.default_pseud]) }
    let(:params) { { commit: "Orphan", id: work1.id, work_ids: [work1.id, work2.id] } }

    before do
      fake_login_known_user(multiple_works_user)
    end

    context "when logged in as a user" do
      it "returns the works specified in the work_ids parameters" do
        post :confirm_delete_multiple, params: params

        expect(assigns(:works)).to include(work1)
        expect(assigns(:works)).to include(work2)
      end
    end

    context "when logged in as a banned user" do
      it "returns the works specified in the work_ids parameters" do
        multiple_works_user.update!(banned: true)
        post :confirm_delete_multiple, params: params

        expect(assigns(:works)).to include(work1)
        expect(assigns(:works)).to include(work2)
      end
    end

    context "when logged in as a suspended user" do
      it "errors and redirects to user page" do
        multiple_works_user.update!(suspended: true, suspended_until: 1.week.from_now)

        post :confirm_delete_multiple, params: params
        it_redirects_to_simple(user_path(multiple_works_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end
  end

  describe "delete_multiple" do
    let!(:multiple_work1) do
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 1")
    end
    let!(:multiple_work2) do
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 2")
    end

    before do
      fake_login_known_user(multiple_works_user)
    end

    context "when logged in as a user" do
      before do
        post :delete_multiple, params: { id: multiple_work1.id, work_ids: [multiple_work1.id, multiple_work2.id] }
      end

      # already covered - just for completeness
      it "deletes all the works" do
        expect { Work.find(multiple_work1.id) }
          .to raise_exception(ActiveRecord::RecordNotFound)
        expect { Work.find(multiple_work2.id) }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "displays a notice" do
        expect(flash[:notice]).to eq "Your works Work 1, Work 2 were deleted."
      end
    end

    context "when logged in as a banned user" do
      before do
        multiple_works_user.update!(banned: true)
        post :delete_multiple, params: { id: multiple_work1.id, work_ids: [multiple_work1.id, multiple_work2.id] }
      end

      it "deletes all the works" do
        expect { Work.find(multiple_work1.id) }
          .to raise_exception(ActiveRecord::RecordNotFound)
        expect { Work.find(multiple_work2.id) }
          .to raise_exception(ActiveRecord::RecordNotFound)
      end

      it "displays a notice" do
        expect(flash[:notice]).to eq "Your works Work 1, Work 2 were deleted."
      end
    end

    context "when logged in as a suspended user" do
      before do
        multiple_works_user.update!(suspended: true, suspended_until: 1.week.from_now)
        post :delete_multiple, params: { id: multiple_work1.id, work_ids: [multiple_work1.id, multiple_work2.id] }
      end

      it "errors and redirects to user page" do
        it_redirects_to_simple(user_path(multiple_works_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end
  end

  describe "update_multiple" do
    let(:multiple_works_user) { create(:user) }
    let!(:multiple_work1) do
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 1",
             comment_permissions: :disable_anon,
             moderated_commenting_enabled: true)
    end
    let!(:multiple_work2) do
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 2",
             comment_permissions: :disable_all,
             moderated_commenting_enabled: true)
    end
    let(:params) do
      {
        work_ids: [multiple_work1.id, multiple_work2.id],
        work: {
          rating_string: "",
          fandom_string: "",
          relationship_string: "",
          character_string: "",
          freeform_string: "",
          pseuds_to_remove: [""],
          pseuds_to_add: "",
          collections_to_add: "",
          language_id: "",
          work_skin_id: "",
          restricted: "",
          comment_permissions: "",
          moderated_commenting_enabled: ""
        }
      }.merge(work_params)
    end

    before do
      fake_login_known_user(multiple_works_user)
    end

    context 'adjusting commenting ability' do
      let(:work_params) {
        {
          work: {
            comment_permissions: "enable_all",
            moderated_commenting_enabled: "0"
          }
        }
      }

      it "changes the comment_permissions option to 0" do
        put :update_multiple, params: params
        assigns(:works).each do |work|
          expect(work.comment_permissions).to eq("enable_all")
        end
      end

      it "changes the moderated_commenting_enabled option to false" do
        put :update_multiple, params: params
        assigns(:works).each do |work|
          expect(work.moderated_commenting_enabled).to be false
        end
      end
    end

    context "updating creators" do
      let(:pseud_to_invite) do
        user = FactoryBot.create(:user)
        user.preference.update!(allow_cocreator: true)
        user.default_pseud
      end

      let(:other_editor_pseud) { create(:pseud, user: multiple_works_user) }

      let(:work_params) {
        {
          work: {
            pseuds_to_add: pseud_to_invite.name,
            current_user_pseud_ids: [other_editor_pseud.id]
          }
        }
      }

      before do
        put :update_multiple, params: params
      end

      it "invites coauthors when pseuds_to_add param exists" do
        assigns(:works).each do |work|
          expect(work.pseuds.reload).not_to include(pseud_to_invite)
          expect(work.creatorships.unapproved.map(&:pseud)).to include(pseud_to_invite)
        end
      end

      it "modifies the editor's pseuds when current_user_pseud_ids param exists" do
        assigns(:works).each do |work|
          work.pseuds.reload
          expect(work.pseuds).to include(other_editor_pseud)
          expect(work.pseuds).not_to include(multiple_works_user.default_pseud)
        end
      end
    end

    context "with archive_warning_strings" do    
      context "when string doesn't match a canonical ArchiveWarning name" do
        let(:work_params) {
          { work: { archive_warning_strings: ["Nonexistent Warning"] } }
        }

        before do
          put :update_multiple, params: params
        end

        it "doesn't update the works' archive warnings" do
          assigns(:works).each do |work|
            expect(work.archive_warnings.reload.map(&:name)).not_to include("Nonexistent Warning")
            expect(work.archive_warnings.reload.map(&:name)).to include(ArchiveConfig.WARNING_NONE_TAG_NAME)
          end
        end
      end

      context "when string matches a canonical ArchiveWarning name" do
        let(:work_params) {
          {
            work: {
              archive_warning_strings: [ArchiveConfig.WARNING_CHAN_TAG_NAME]
            }
          }
        }

        before do
          put :update_multiple, params: params
        end

        it "replaces the works' archive warnings" do
          assigns(:works).each do |work|
            expect(work.archive_warnings.reload.map(&:name)).not_to include(ArchiveConfig.WARNING_NONE_TAG_NAME)
            expect(work.archive_warnings.reload.map(&:name)).to include(ArchiveConfig.WARNING_CHAN_TAG_NAME)
          end
        end
      end
    end

    context "with category_strings" do
      context "when string doesn't match a canonical Category name" do
        let(:work_params) {
          { 
            work: { category_strings: ["Nonexistent Category"] }
          }
        }

        before do
          put :update_multiple, params: params
        end

        it "doesn't update the works' categories" do
          assigns(:works).each do |work|
            expect(work.categories.reload.map(&:name)).not_to include("Nonexistent Category")
          end
        end
      end

      context "when string matches a canonical Category name" do
        let(:work_params) {
          { work: { category_strings: [ArchiveConfig.CATEGORY_SLASH_TAG_NAME] } }
        }

        before do
          put :update_multiple, params: params
        end

        it "replaces the works' categories" do
          assigns(:works).each do |work|
            expect(work.categories.reload.map(&:name)).to include(ArchiveConfig.CATEGORY_SLASH_TAG_NAME)
          end
        end
      end
    end 
  
    context "with rating_string" do    
      context "when string doesn't match a canonical Rating name" do
        let(:work_params) { { work: { rating_string: "Nonexistent Rating" } } }

        before do
          put :update_multiple, params: params
        end

        it "doesn't update the works' rating" do
          assigns(:works).each do |work|
            expect(work.ratings.reload.map(&:name)).not_to include("Nonexistent Rating")
            expect(work.ratings.reload.map(&:name)).to include(ArchiveConfig.RATING_DEFAULT_TAG_NAME)
          end
        end
      end

      context "when string matches a canonical Rating name" do
        let(:work_params) {
          { work: { rating_string: ArchiveConfig.RATING_EXPLICIT_TAG_NAME } }
        }

        before do
          put :update_multiple, params: params
        end

        it "replaces the works' rating" do
          assigns(:works).each do |work|
            expect(work.ratings.reload.map(&:name)).not_to include(ArchiveConfig.RATING_DEFAULT_TAG_NAME)
            expect(work.ratings.reload.map(&:name)).to include(ArchiveConfig.RATING_EXPLICIT_TAG_NAME)
          end
        end
      end
    end

    context "when user is banned" do
      let(:work_params) do
        {
          work: {
            comment_permissions: "enable_all",
            moderated_commenting_enabled: "0"
          }
        }
      end
      
      it "errors and redirects to user page" do
        multiple_works_user.update!(banned: true)
        put :update_multiple, params: params

        it_redirects_to_simple(user_path(multiple_works_user))
        expect(flash[:error]).to include("Your account has been banned")
      end
    end
    
    context "when user is suspended" do
      let(:work_params) do
        {
          work: {
            comment_permissions: "enable_all",
            moderated_commenting_enabled: "0"
          }
        }
      end

      it "errors and redirects to user page" do
        multiple_works_user.update!(suspended: true, suspended_until: 1.week.from_now)
        put :update_multiple, params: params
        
        it_redirects_to_simple(user_path(multiple_works_user))
        expect(flash[:error]).to include("Your account has been suspended")
      end
    end
  end
end
