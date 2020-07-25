# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  let(:user) { create(:user) }
  let!(:work) { create(:work, authors: [user.default_pseud], posted: true) }

  context "update_tags" do
    before do
      fake_login_known_user(user)
    end

    it "should render edit tags when there are invalid tags" do
      allow_any_instance_of(Work).to receive(:invalid_tags).and_return([create(:unsorted_tag)])

      patch :update_tags, params: { id: work }
      expect(response).to render_template "edit_tags"

      allow_any_instance_of(Work).to receive(:invalid_tags).and_call_original
    end

    it "should throw error when there are invalid tags and trying to preview" do
      allow_any_instance_of(Work).to receive(:invalid_tags).and_return([create(:unsorted_tag)])

      expect {patch :update_tags, params: { id: work, preview_button: true } }.to raise_error UncaughtThrowError

      allow_any_instance_of(Work).to receive(:invalid_tags).and_call_original
    end
  end

  context "preview_tags" do
    it "should render preview tags" do
      fake_login_known_user(user)

      get :preview_tags, params: { id: work }
      expect(response).to render_template "preview_tags"
    end
  end
end
