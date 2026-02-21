require "spec_helper"

describe TagIndexer, tag_search: true do
  describe ".index_all" do
    it "uses configured shard count when creating the index" do
      allow(TagIndexer).to receive(:delete_index)
      allow(TagIndexer).to receive(:create_index)
      allow(TagIndexer).to receive(:index_from_db)

      TagIndexer.index_all

      expect(TagIndexer).to have_received(:create_index).with(shards: ArchiveConfig.TAGS_SHARDS)
    end
  end
end
