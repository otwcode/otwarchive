require "spec_helper"

describe WorkIndexer, work_search: true do
  describe "#index_documents" do
    let(:work) { create(:work) }
    let(:indexer) { WorkIndexer.new([work.id]) }

    context "when a work in the batch has no stat_counter" do
      before { work.stat_counter.delete }

      it "doesn't error" do
        expect { indexer.index_documents }.not_to raise_exception
      end
    end
  end
end
