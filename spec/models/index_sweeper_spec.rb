require 'spec_helper'

describe IndexSweeper do

  describe "#async_cleanup" do
    it "should index items that were expected but not found" do
      expect(AsyncIndexer).to receive(:index).with(Work, [2], "cleanup")

      IndexSweeper.async_cleanup(Work, [1,2], [1])
    end
  end

  it "should ensure the failure stores exist" do
    IndexSweeper.new({}, WorkIndexer)

    expect(AsyncIndexer::REDIS.get("WorkIndexer:first_failure_store")).to eq([].to_json)
    expect(AsyncIndexer::REDIS.get("WorkIndexer:second_failure_store")).to eq([].to_json)
    expect(AsyncIndexer::REDIS.get("WorkIndexer:permanent_failure_store")).to eq([].to_json)
  end

  it "should move documents that fail once to first_failure_store" do
    sweeper = IndexSweeper.new(batch, WorkIndexer)
    indexer = AsyncIndexer.new(WorkIndexer, "failures")

    expect(AsyncIndexer).to receive(:new).with(WorkIndexer, "failures").and_return(indexer)
    expect(indexer).to receive(:enqueue_ids).with([1])

    sweeper.process_batch_failures

    store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:first_failure_store"))
    expect(store).to include({"1" => { "an error" => "with a message" }})
  end

  it "should move documents that fail twice to second_failure_store" do
    sweeper = IndexSweeper.new(batch, WorkIndexer)
    indexer = AsyncIndexer.new(WorkIndexer, "failures")

    AsyncIndexer::REDIS.set(
      "WorkIndexer:first_failure_store",
      [{"1" => { "an error" => "with a message" }}].to_json
    )

    expect(AsyncIndexer).to receive(:new).with(WorkIndexer, "failures").and_return(indexer)
    expect(indexer).to receive(:enqueue_ids).with([1])

    sweeper.process_batch_failures

    first_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:first_failure_store"))
    second_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:second_failure_store"))

    expect(first_store).to eq([])
    expect(second_store).to include({"1" => { "an error" => "with a message" }})
  end

  it "should move documents that fail three times to permanent_failure_store" do
    sweeper = IndexSweeper.new(batch, WorkIndexer)

    AsyncIndexer::REDIS.set(
      "WorkIndexer:second_failure_store",
      [{"1" => { "an error" => "with a message" }}].to_json
    )

    expect(AsyncIndexer).not_to receive(:new).with(WorkIndexer, "failures")

    sweeper.process_batch_failures

    second_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:second_failure_store"))
    permanent_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:permanent_failure_store"))

    expect(second_store).to eq([])
    expect(permanent_store).to include({"1" => { "an error" => "with a message" }})
  end

  it "should remove documents from stores if they succeed" do
    batch = {
      "errors" => false,
      "items" => [
        { "update" => { "_id" => "1" } },
        { "delete" => { "_id" => "2" } },
        { "index" => { "_id" => "3" } }
      ]
    }

    sweeper = IndexSweeper.new(batch, WorkIndexer)

    AsyncIndexer::REDIS.set(
      "WorkIndexer:first_failure_store",
      [{"1" => { "an error" => "a message" }}].to_json
    )

    AsyncIndexer::REDIS.set(
      "WorkIndexer:second_failure_store",
      [{"2" => { "an error" => "a message" }}].to_json
    )

    AsyncIndexer::REDIS.set(
      "WorkIndexer:permanent_failure_store",
      [{"3" => { "an error" => "a message" }}].to_json
    )

    expect(AsyncIndexer).not_to receive(:new)

    sweeper.process_batch_failures

    first_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:first_failure_store"))
    second_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:second_failure_store"))
    permanent_store = JSON.parse(AsyncIndexer::REDIS.get("WorkIndexer:permanent_failure_store"))

    expect(first_store).to eq([])
    expect(second_store).to eq([])
    expect(permanent_store).to eq([])
  end

  it "should grab the elasticsearch ids expected by the indexer for retries" do
    work = create(:work)
    work.stat_counter.update(id: 3)

    sweeper = IndexSweeper.new(batch(work.id), StatCounterIndexer)
    indexer = AsyncIndexer.new(StatCounterIndexer, "failures")

    expect(AsyncIndexer).to receive(:new).with(StatCounterIndexer, "failures").at_least(:once).and_return(indexer)
    expect(indexer).to receive(:enqueue_ids).with([work.stat_counter.id]).at_least(:once).and_call_original

    expect(sweeper.process_batch_failures).to be(true)
  end

  private

  def batch(id = 1)
    {
      "errors" => true,
      "items" => [
        {
          "update" => {
            "_id" => id,
            "error" => {
              "an error" => "with a message"
            }
          }
        }
      ]
    }
  end

end
