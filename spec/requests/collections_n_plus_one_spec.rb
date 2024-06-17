# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the collections controller" do
  include LoginMacros

  shared_examples "produces a constant number of queries" do
    warmup { subject.call }

    it "produces a constant number of queries" do
      expect { subject.call }
        .to perform_constant_number_of_queries
    end
  end

  describe "#index", n_plus_one: true do
    context "when viewing a work's approved collections" do
      let!(:work) { create(:work) }

      populate do |n|
        create_list(:collection, n).each do |collection|
          ci = create(:collection_item, collection: collection, item: work)
          ci.approve_by_user
          ci.save!
          collection.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get collections_path(work_id: work)
        end
      end

      it_behaves_like "produces a constant number of queries"
    end

    context "when viewing collections moderated by a specific user" do
      let!(:user) { create(:user) }

      populate do |n|
        create_list(:collection, n).each do |collection|
          collection.collection_participants << create(:collection_participant, pseud: user.default_pseud, participant_role: "Moderator")
          collection.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get collections_path(user_id: user)
        end
      end

      it_behaves_like "produces a constant number of queries"
    end

    context "when viewing all collections" do
      populate do |n|
        create_list(:collection, n).each do |collection|
          collection.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get collections_path
        end
      end

      it_behaves_like "produces a constant number of queries"
    end
  end
end
