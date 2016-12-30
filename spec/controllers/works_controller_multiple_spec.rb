require "spec_helper"

describe WorksController do
  include LoginMacros

  let(:multiple_user_pseud) { create(:pseud) }
  let!(:multiple_works_user) {
    user = create(:user)
    user.pseuds << multiple_user_pseud
    user
  }

  # describe "show_multiple" do
  #   it "should select only the works for the specified pseud" do
  #     work1 = create(:work, authors: [multiple_works_user.default_pseud], posted: true)
  #     work2 = create(:work, authors: [multiple_user_pseud], posted: true)
  #     fake_login_known_user(multiple_works_user)
  #     get :show_multiple, pseud_id: multiple_user_pseud.id
  #     expect(assigns(:works)).to include(work2)
  #     expect(assigns(:works)).not_to include(work1)
  #   end
  # end

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
             posted: true) }
    let(:multiple_work2) {
      create(:work,
             authors: [multiple_works_user.default_pseud],
             title: "Work 2",
             posted: true) }

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
    it "should convert the anon_commenting_disabled parameter to '0'" do
    end

    it "should convert the moderated_commenting_enabled parameter to '0'" do
    end

    it "should display an error if any of the works can't be updated" do
    end

    it "should display an error if any errors occurred while updating the works" do
    end
  end
end

