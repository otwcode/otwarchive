require "spec_helper"

describe AsyncIndexer do
  include ActiveJob::TestHelper

  it "enqueues IDs" do
    freeze_time
    batch_key = "WorkIndexer:34:#{Time.now.to_i}"

    expect do
      AsyncIndexer.index(Work, [34], :background)
    end.to enqueue_job.on_queue("reindex_low").with(batch_key)

    expect(AsyncIndexer::REDIS.smembers(batch_key)).to contain_exactly("34")
  end

  context "when persistent indexing failures occur" do
    let(:work_id) { create(:work).id }

    before do
      # Make batch indexing always fail.
      allow($elasticsearch).to receive(:bulk) do |options|
        {
          "errors" => true,
          "items" => options[:body].map do |line|
            action = line.keys.first
            next unless (id = line[action]["_id"])

            {
              action.to_s => {
                "_id" => id,
                "error" => { "an error" => "with a message" }
              }
            }
          end.compact
        }
      end
    end

    it "tries indexing IDs up to 3 times" do
      expect(BookmarkedWorkIndexer).to receive(:new).with([work_id.to_s])
        .exactly(3).times
        .and_call_original

      expect do
        AsyncIndexer.index(BookmarkedWorkIndexer, [work_id], :main)
      end.to enqueue_job

      2.times do
        # Batch keys in Redis contain a timestamp. Ensure that each retry has
        # a different batch key.
        travel(1.second)
        expect { perform_enqueued_jobs }
          .to enqueue_job.on_queue("reindex_failures")
      end

      # The third failure does not enqueue a retry.
      travel(1.second)
      expect { perform_enqueued_jobs }
        .not_to enqueue_job
    end
  end

  context "when there are no IDs to index" do
    it "doesn't call the indexer" do
      expect(AsyncIndexer::REDIS).to receive(:smembers).and_return([])
      expect(WorkIndexer).not_to receive(:new)

      AsyncIndexer.index(WorkIndexer, [34], :main)
      perform_enqueued_jobs
    end
  end
end
