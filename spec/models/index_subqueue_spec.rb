require 'spec_helper'


describe IndexSubqueue do
  let(:subqueue) { IndexSubqueue.new("index:work:main:1234567:0") }

  it "should have ids added to it" do
    subqueue.add_ids([1,2,3,4])
    expect(subqueue.ids).to eq(%w(1 2 3 4))
  end

  it "should get its target class from the name" do
    expect(subqueue.klass).to eq(Work)
  end

  it "should get its label from the name" do
    expect(subqueue.label).to eq("main")
  end

  describe "#run" do
    let(:work) { create(:posted_work) }

    it "reindexes new works" do
      subqueue.add_ids([work.id])
      expect(subqueue).to receive(:respond_to_success).and_call_original
      expect(Work).to receive(:successful_reindex).and_call_original
      subqueue.run

      # FIXME: rewrite for new search
      # Work.tire.index.refresh
      # expect(WorkSearch.new.search_results.items).to include(work)
    end
  end
end
