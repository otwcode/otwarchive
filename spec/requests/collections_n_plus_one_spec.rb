# frozen_string_literal: true

require "spec_helper"

describe "n+1 queries in the collections controller" do
  describe "#index", n_plus_one: true do
    populate do |n|
      CollectionIndexer.prepare_for_testing
      create_list(:collection, n, challenge: create(:gift_exchange))
      run_all_indexing_jobs
    end

    subject do
      proc do
        get collections_path
      end
    end

    warmup { subject.call }

    it "performs about 1 query per collection" do
      expect do
        subject.call
        expect(response.body.scan('<li class="collection ').size).to eq(current_scale.to_i)
      end.to perform_linear_number_of_queries(slope: 1) # The subcollections count query which can't be eliminated with includes
    end
  end
end
