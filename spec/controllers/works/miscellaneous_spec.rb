# frozen_string_literal: true
require "spec_helper"

describe WorksController do
  include LoginMacros
  include RedirectExpectationHelper

  context "reindex" do
    let(:work) { create(:work) }

    context "if the user is an admin or tag wrangler" do
      let(:admin) { create(:admin) }

      before do
        fake_login_admin(admin)
      end

      it "should queue the work for reindex" do
        expect(RedisSearchIndexQueue).to receive(:queue_works)
        post :reindex, params: { id: work }
      end
      it "should redirect to the root path and display a success message" do
        post :reindex, params: { id: work }
        it_redirects_to_with_notice(root_path, "Work queued to be reindexed")
      end
    end

    context "if the user is not an admin" do
      it "should redirect to the root path and display an error" do
        fake_login
        post :reindex, params: { id: work }
        it_redirects_to_with_error(root_path, "Sorry, you don't have permission to perform this action.")
      end
    end
  end
end
