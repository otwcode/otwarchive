require "spec_helper"

describe Indexer do
  describe ".index_from_db" do
    let(:async_indexer) { instance_double(AsyncIndexer, enqueue_ids: true) }
    let(:indexables) { instance_double(ActiveRecord::Relation, count: 2) }

    before do
      stub_const("TestIndexer", Class.new(Indexer))
      allow(TestIndexer).to receive(:klass).and_return("Work")
      allow(TestIndexer).to receive(:indexables).and_return(indexables)
      allow(ArchiveConfig).to receive(:SEARCH_INDEXER_BATCH_SIZE).and_return(1)
      allow(AsyncIndexer).to receive(:new).and_return(async_indexer)
    end

    it "uses the configured batch size when indexing" do
      group = [double(id: 12)]

      expect(indexables).to receive(:find_in_batches).with(batch_size: 1).and_yield(group)
      expect(async_indexer).to receive(:enqueue_ids).with([12])

      TestIndexer.index_from_db
    end
  end
end
