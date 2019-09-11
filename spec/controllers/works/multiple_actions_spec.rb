# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let!(:multiple_works_user) { create(:user) }

  describe "edit_multiple" do
    it "should redirect to the orphan path when the Orphan button was clicked" do
      work1 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work2 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work_ids = [work1.id, work2.id]
      fake_login_known_user(multiple_works_user)
      post :edit_multiple, params: { id: work1.id, work_ids: work_ids, commit: "Orphan" }
      it_redirects_to new_orphan_path(work_ids: work_ids)
    end
  end

  describe "confirm_delete_multiple" do
    it "should return the works specified in the work_ids parameters" do
      work1 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work2 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      fake_login_known_user(multiple_works_user)
      params = { commit: "Orphan", id: work1.id, work_ids: [work1.id, work2.id] }
      post :confirm_delete_multiple, params: params
      expect(assigns(:works)).to include(work1)
      expect(assigns(:works)).to include(work2)
    end
  end

  describe "delete_multiple" do
    let(:multiple_work1) {
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 1",
             posted: true)
    }
    let(:multiple_work2) {
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 2",
             posted: true)
    }

    before do
      fake_login_known_user(multiple_works_user)
      post :delete_multiple, params: { id: multiple_work1.id, work_ids: [multiple_work1.id, multiple_work2.id] }
    end

    # already covered - just for completeness
    it "should delete all the works" do
      expect { Work.find(multiple_work1.id) }.to raise_exception(ActiveRecord::RecordNotFound)
      expect { Work.find(multiple_work2.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "should display a notice" do
      expect(flash[:notice]).to eq "Your works Work 1, Work 2 were deleted."
    end
  end

  describe "update_multiple" do
    let(:multiple_works_user) { create(:user) }
    let(:multiple_work1) {
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 1",
             anon_commenting_disabled: true,
             moderated_commenting_enabled: true,
             posted: true)
    }
    let(:multiple_work2) {
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 2",
             anon_commenting_disabled: true,
             moderated_commenting_enabled: true,
             posted: true)
    }
    let(:params) {
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
          restricted: "0",
          unrestricted: "0",
          anon_commenting_disabled: "",
          moderated_commenting_enabled: ""
        }
      }.merge(work_params)
    }

    before do
      fake_login_known_user(multiple_works_user)
    end

    context 'adjusting commenting ability' do
      let(:work_params) {
        {
          work: {
            anon_commenting_disabled: "allow_anon",
            moderated_commenting_enabled: "not_moderated"
          }
        }
      }

      it "should convert the anon_commenting_disabled parameter to false" do
        put :update_multiple, params: params
        assigns(:works).each do |work|
          expect(work.anon_commenting_disabled).to be false
        end
      end

      it "should convert the moderated_commenting_enabled parameter to false" do
        put :update_multiple, params: params
        assigns(:works).each do |work|
          expect(work.moderated_commenting_enabled).to be false
        end
      end
    end

    context "updating creators" do
      let(:pseud_to_invite) do
        user = FactoryBot.create(:user)
        user.preference.update(allow_cocreator: true)
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
  end
end
