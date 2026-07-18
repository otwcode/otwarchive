require "spec_helper"

describe PseudIndexer, pseud_search: true do
  describe ".index_all" do
    it "uses configured shard count when creating the index" do
      allow(PseudIndexer).to receive(:index_from_db)
      expect(PseudIndexer).to receive(:create_index).with(shards: ArchiveConfig.PSEUD_SHARDS)

      PseudIndexer.index_all
    end
  end

  describe "#index_documents" do
    let(:pseud) { create(:pseud) }
    let(:indexer) { PseudIndexer.new([pseud.id]) }

    context "when a pseud in the batch has no user" do
      before { pseud.user.delete }

      it "doesn't error" do
        expect { indexer.index_documents }.not_to raise_exception
      end
    end
  end
end
