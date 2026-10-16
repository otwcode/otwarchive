require "spec_helper"

describe Indexer do
  describe ".index_from_db" do
    let!(:work1) { create(:work) }
    let!(:work2) { create(:work) }
    let(:async_indexer) { instance_double(AsyncIndexer, enqueue_ids: true) }

    before do
      allow(ArchiveConfig).to receive(:SEARCH_INDEXER_BATCH_SIZE).and_return(1)
      allow(AsyncIndexer).to receive(:new).and_return(async_indexer)
    end

    it "uses the configured batch size when indexing" do
      WorkIndexer.index_from_db

      expect(async_indexer).to have_received(:enqueue_ids).twice
    end
  end
end
