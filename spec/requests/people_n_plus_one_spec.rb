# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the people controller" do
  describe "#search", n_plus_one: true do
    context "when viewing people in a collection" do
      let!(:collection) { create(:collection) }

      populate do |n|
        create_list(:collection_participant, n, collection: collection).each do |participant|
          participant.pseud.icon.attach(io: File.open(Rails.root.join("features/fixtures/icon.gif")), filename: "icon.gif", content_type: "image/gif")
        end
      end

      subject do
        proc do
          get collection_people_path(collection_id: collection)
        end
      end

      warmup { subject.call }

      it "produces a constant number of queries" do
        expect { subject.call }
          .to perform_constant_number_of_queries
      end
    end
  end
end
