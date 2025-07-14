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

    describe "PATCH #mark_for_later" do
      it "marks the work for later" do
        patch :mark_for_later, params: { id: work.id }
        it_redirects_to_simple(root_path)
        expect(flash[:notice]).to include("This work was added to your ")
        expect(flash[:notice]).to include("Marked for Later list")
        expect(user.readings.first.toread).to be true
      end
    end

    describe "PATCH #mark_as_read" do
      it "removes the work from mark for later" do
        patch :mark_as_read, params: { id: work.id }
        it_redirects_to_simple(root_path)
        expect(flash[:notice]).to include("This work was removed from your ")
        expect(flash[:notice]).to include("Marked for Later list")
        expect(user.readings.first.toread).to be false
      end
    end
  end
end
