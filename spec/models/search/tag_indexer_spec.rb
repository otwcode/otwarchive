require "spec_helper"

describe TagIndexer, tag_search: true do
  describe ".index_all" do
    it "uses configured shard count when creating the index" do
      allow(TagIndexer).to receive(:index_from_db)
      expect(TagIndexer).to receive(:create_index).with(shards: ArchiveConfig.TAG_SHARDS)

      TagIndexer.index_all
    end
  end
end
