require 'spec_helper'

describe KudosController do
  include LoginMacros
  include RedirectExpectationHelper

  describe 'create' do
    context "when regular work is posted" do
      let(:user) { create(:user) }
      let!(:work) { create(:posted_work, authors: [user.pseuds.first]) }

      context "when work owner is logged in" do
        before do
          fake_login_known_user(user)
        end

        it 'rejects the owner of the work' do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
          expect(response).to have_http_status :redirect
          expect(flash[:comment_error]).to include("You can't leave kudos on your own work.")
        end

        it 'rejects the owner of the work in json format' do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" }, format: :js }
          expect(JSON.parse(response.body)["errors"]["cannot_be_author"]).to include("^You can't leave kudos on your own work.")
        end
      end
    end

    context "when restricted work is posted" do
      let!(:work) { create(:restricted_work) }

      it 'rejects guests' do
        post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        expect(response).to have_http_status :redirect
        expect(flash[:comment_error]).to include("You can't leave guest kudos on a restricted work.")
      end
    end
  end
end