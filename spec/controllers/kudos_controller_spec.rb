# frozen_string_literal: true

require 'spec_helper'

describe KudosController do
  include LoginMacros
  include RedirectExpectationHelper

  describe 'create' do
    context "when a regular work is posted" do
      let(:user) { create(:user) }
      let!(:work) { create(:posted_work, authors: [user.pseuds.first]) }

      context "when a kudo is posted to the work" do
        before do
          post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        end

        it "redirects to work path" do
          expect(response).to redirect_to(work_path(work))
        end

        it "sets flash notice" do
          expect(flash[:comment_notice]).to eq("Thank you for leaving kudos!")
        end
      end

      context "when a kudo is posted to the work's first chapter" do
        before do
          post :create, params: { kudo: { commentable_id: work.chapters.first.id, commentable_type: "Chapter" } }
        end

        it "redirects to chapter path" do
          expect(response).to redirect_to(work_chapter_path(work.chapters.first))
        end

        it "sets flash notice" do
          expect(flash[:comment_notice]).to eq("Thank you for leaving kudos!")
        end
      end

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



    context "when a kudo to a non existant work is posted" do
      before do
        post :create, params: { kudo: { commentable_id: "333", commentable_type: "Work" } }
      end

      it "redirects to root path" do
        expect(response).to redirect_to(root_path)
      end

      it "sets flash error comment" do
        expect(flash[:comment_error]).to eq("We couldn't save your kudos, sorry!")
      end
    end

    context "when a restricted work is posted" do
      let!(:work) { create(:restricted_work) }

      it 'rejects guests' do
        post :create, params: { kudo: { commentable_id: work.id, commentable_type: "Work" } }
        expect(response).to have_http_status :redirect
        expect(flash[:comment_error]).to include("You can't leave guest kudos on a restricted work.")
      end
    end
  end
end
