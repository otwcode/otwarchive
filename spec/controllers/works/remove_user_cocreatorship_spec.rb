# frozen_string_literal: true

require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  describe "PATCH #remove_user_creatorship" do
    let(:user) { create(:user) }
    let(:other_pseud) { create(:pseud, user: user) }
    let(:second_creator) { create(:user) }

    context "all co-creators are pseuds of same user" do
      before do
        fake_login_known_user(user)
      end

      let(:work) { create(:work, authors: [user.default_pseud, other_pseud]) }

      it "does not remove creatorship and redirects to orphan page" do
        patch :remove_user_creatorship, params: { id: work.id }

        expect(work.pseuds.reload).to contain_exactly(user.default_pseud, other_pseud)
        it_redirects_to(new_orphan_path(work_id: work.id))
      end
    end

    context "co-creators of multiple users" do
      before do
        fake_login_known_user(user)
      end

      let(:work) { create(:work, authors: [user.default_pseud, second_creator.default_pseud]) }

      it "successfully removes user creatorship" do
        patch :remove_user_creatorship, params: { id: work.id }

        expect(work.pseuds.reload).to contain_exactly(second_creator.default_pseud)
      end
    end
  end
end
