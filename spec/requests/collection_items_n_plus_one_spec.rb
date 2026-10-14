# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the collection items controller" do
  include LoginMacros

  describe "#index" do
    # This test demonstrates that rendering does not raise when the
    # approved_unrevealed_collections association uses strict loading.
    it "renders bookmark items whose bookmarkable is an unrevealed work" do
      user = create(:user)
      collection = create(:unrevealed_collection)
      mystery_work = create(:work, collection_names: collection.name)
      bookmark = create(:bookmark, bookmarkable_id: mystery_work.id, pseud_id: user.default_pseud.id)
      create(:collection_item, item: bookmark, user_approval_status: :approved, collection_approval_status: :approved)

      fake_login_known_user(user)
      get user_collection_items_path(user_id: user, status: "approved")

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Mystery Work")
    end

    context "when viewing collection items for a specific user", n_plus_one: true do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:work, n, authors: [user.default_pseud]).each do |work|
          collection_item = create(:collection_item, item: work)
          collection_item.collection.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get user_collection_items_path(user_id: user)
        end
      end

      before do
        fake_login_known_user(user)
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end
  end
end
