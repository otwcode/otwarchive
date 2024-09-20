# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the people controller" do
  describe "#index", n_plus_one: true do
    context "when viewing people in a collection" do
      let!(:collection) { create(:collection) }

      populate do |n|
        create_list(:collection_participant, n, collection: collection)
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

  describe "#search", n_plus_one: true do
    context "when there are search results" do
      populate do |n|
        PseudIndexer.prepare_for_testing
        create_list(:pseud, n, name: "nplusone")
        run_all_indexing_jobs
      end

      subject do
        proc do
          get search_people_path, params: { "people_search" => { "name" => "nplusone" } }
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
