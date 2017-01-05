# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:multiple_user_pseud) { create(:pseud) }
  let!(:multiple_works_user) {
    user = create(:user)
    user.pseuds << multiple_user_pseud
    user
  }

  describe "edit_multiple" do
    it "should redirect to the orphan path when the Orphan button was clicked" do
      work1 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work2 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work_ids = [work1.id, work2.id]
      fake_login_known_user(multiple_works_user)
      post :edit_multiple, id: work1.id, work_ids: work_ids, commit: "Orphan"
      it_redirects_to new_orphan_path(work_ids: work_ids)
    end
  end

  describe "confirm_delete_multiple" do
    it "should return the works specified in the work_ids parameters" do
      work1 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      work2 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
      fake_login_known_user(multiple_works_user)
      params = { commit: "Orphan", id: work1.id, work_ids: [work1.id, work2.id] }
      post :confirm_delete_multiple, params
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
      post :delete_multiple, id: multiple_work1.id, work_ids: [multiple_work1.id, multiple_work2.id]
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
    let!(:multiple_works_user) { create(:user) }
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
          anon_commenting_disabled: "allow_anon",
          moderated_commenting_enabled: "not_moderated"
        }
      }
    }

    before do
      fake_login_known_user(multiple_works_user)
    end

    it "should convert the anon_commenting_disabled parameter to false" do
      put :update_multiple, params
      assigns(:works).each do |work|
        expect(work.anon_commenting_disabled).to be false
      end
    end

    it "should convert the moderated_commenting_enabled parameter to false" do
      put :update_multiple, params
      assigns(:works).each do |work|
        expect(work.moderated_commenting_enabled).to be false
      end
    end
  end
end
