require 'spec_helper'

describe AsyncIndexer do

  it "should enqueue ids" do
    work = Work.new
    work.id = 34

    indexer = AsyncIndexer.new('WorkIndexer', :background)

    expect(AsyncIndexer).to receive(:new).with('WorkIndexer', :background).and_return(indexer)
    expect(indexer).to receive(:enqueue_ids).with([34]).and_return(true)

    AsyncIndexer.index('Work', [34], :background)
  end

  it "should retry batch errors" do
    work = Work.new
    work.id = 34

    indexer = WorkIndexer.new([34])
    batch = { "errors" => true, "items" => [{ "_id" => 34 }] }
    async_indexer = AsyncIndexer.new(WorkIndexer, "failures")

    expect(AsyncIndexer::REDIS).to receive(:smembers).and_return([34])
    expect(WorkIndexer).to receive(:new).with([34]).and_return(indexer)
    expect(indexer).to receive(:index_documents).and_return(batch)
    expect(AsyncIndexer).to receive(:new).with(WorkIndexer, "failures").and_return(async_indexer)
    expect(async_indexer).to receive(:enqueue_ids).with([34]).and_return(true)

    AsyncIndexer.perform("WorkIndexer:34:#{Time.now.to_i}")
  end

end
