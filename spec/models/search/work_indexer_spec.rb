require "spec_helper"

describe WorkIndexer, work_search: true do
  describe "#index_documents" do
    let(:work) { create(:work) }

    context "when a work in the batch has no stat_counter" do
      let(:indexer) { WorkIndexer.new([work.id]) }

      before { work.stat_counter.delete }

      it "doesn't error" do
        expect { indexer.index_documents }.not_to raise_exception
      end
    end

    context "when there are no IDs in the batch" do
      let(:indexer) { WorkIndexer.new([]) }

      it "returns nil" do
        expect(indexer.index_documents).to be_nil
      end
    end
  end
end
