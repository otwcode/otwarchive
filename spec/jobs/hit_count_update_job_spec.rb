require "spec_helper"

describe HitCountUpdateJob do
  context "when spawned with the RedisJobSpawner" do
    let(:work_id) { work.id }
    let(:stat_counter) { work.stat_counter }

    before do
      stat_counter.update!(hit_count: 3)
      RedisHitCounter.redis.hset("recent_counts", work_id, 10)
    end

    shared_examples "clears the recent counts hash" do
      it "clears the recent counts hash" do
        RedisJobSpawner.perform_now("HitCountUpdateJob")

        expect(RedisHitCounter.redis.hgetall("recent_counts")).to \
          eq({})
      end
    end

    context "when the work is visible" do
      let(:work) { create(:work) }

      it "updates the stat counters from redis" do
        RedisJobSpawner.perform_now("HitCountUpdateJob")

        expect(stat_counter.reload.hit_count).to eq(13)
      end

      include_examples "clears the recent counts hash"
    end

    shared_examples "doesn't add the hits" do
      it "doesn't add the hits" do
        RedisJobSpawner.perform_now("HitCountUpdateJob")

        expect(stat_counter.reload.hit_count).to eq(3)
      end
    end

    context "when the work is a draft" do
      let(:work) { create(:draft) }

      include_examples "doesn't add the hits"
      include_examples "clears the recent counts hash"
    end

    context "when the work is hidden by an admin" do
      let(:work) { create(:work, hidden_by_admin: true) }

      include_examples "doesn't add the hits"
      include_examples "clears the recent counts hash"
    end

    context "when the work is in an unrevealed collection" do
      let(:collection) { create(:unrevealed_collection) }
      let(:work) { create(:work, collections: [collection]) }

      include_examples "doesn't add the hits"
      include_examples "clears the recent counts hash"
    end

    context "when the work doesn't exist" do
      let(:work_id) { 42 }
      let(:stat_counter) { StatCounter.create(work_id: work_id) }

      include_examples "doesn't add the hits"
      include_examples "clears the recent counts hash"
    end
  end
end
