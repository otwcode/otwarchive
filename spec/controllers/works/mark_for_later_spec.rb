# frozen_string_literal: true

require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let!(:work) { create(:work, authors: [user.pseuds.first]) }

  context "when work owner is logged in" do
    before do
      fake_login_known_user(user)
    end

    describe "POST #mark_for_later" do
      it "marks the work for later" do
        post :mark_for_later, params: { id: work.id }
        it_redirects_to_simple(root_path)
        expect(flash[:notice]).to include("This work was added to your ")
        expect(flash[:notice]).to include("Marked for Later list")
      end
    end

    describe "DELETE #mark_as_read" do
      it "removes the work from mark for later" do
        delete :mark_as_read, params: { id: work.id }
        it_redirects_to_simple(root_path)
        expect(flash[:notice]).to include("This work was removed from your ")
        expect(flash[:notice]).to include("Marked for Later list")
      end
    end
  end
end
