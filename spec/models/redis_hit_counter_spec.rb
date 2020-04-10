require "spec_helper"

describe RedisHitCounter do
  let(:hit_counter) { RedisHitCounter.new }
  let(:work_id) { 42 }
  let(:ip_address) { "127.0.0.1" }

  describe "#current_timestamp" do
    it "returns the previous date at 2:59 AM UTC" do
      Delorean.time_travel_to "2020/01/30 2:59 UTC" do
        expect(hit_counter.current_timestamp).to eq("20200129")
      end
    end

    it "returns the current date at 3:00 AM UTC" do
      Delorean.time_travel_to "2020/01/30 3:00 UTC" do
        expect(hit_counter.current_timestamp).to eq("20200130")
      end
    end

    it "returns the current date at 3:01 AM UTC" do
      Delorean.time_travel_to "2020/01/30 3:01 UTC" do
        expect(hit_counter.current_timestamp).to eq("20200130")
      end
    end
  end

  describe "#add" do
    context "when the IP address hasn't visited" do
      it "records the IP address and increments the count" do
        Delorean.time_travel_to "2020/01/30 3:05 UTC" do
          hit_counter.add(work_id, ip_address)
        end

        expect(hit_counter.redis.smembers("#{work_id}:20200130")).to \
          eq([ip_address])
        expect(hit_counter.redis.hgetall("keys")).to \
          eq({ "#{work_id}:20200130" => "20200130" })
        expect(hit_counter.redis.hgetall("recent_counts")).to \
          eq({ work_id.to_s => "1" })
      end
    end

    context "when the IP address has already visited after 3 AM" do
      before do
        Delorean.time_travel_to "2020/01/30 3:01 UTC" do
          hit_counter.add(work_id, ip_address)
        end

        hit_counter.redis.del("recent_counts")
      end

      it "doesn't increment the count" do
        Delorean.time_travel_to "2020/01/30 3:02 UTC" do
          hit_counter.add(work_id, ip_address)
        end

        expect(hit_counter.redis.hgetall("recent_counts")).to \
          eq({})
      end
    end

    context "when the IP address has already visited before 3 AM" do
      before do
        Delorean.time_travel_to "2020/01/30 2:59 UTC" do
          hit_counter.add(work_id, ip_address)
        end

        hit_counter.redis.del("recent_counts")
      end

      it "increments the count" do
        Delorean.time_travel_to "2020/01/30 3:02 UTC" do
          hit_counter.add(work_id, ip_address)
        end

        expect(hit_counter.redis.hgetall("recent_counts")).to \
          eq({ work_id.to_s => "1" })
      end
    end
  end

  describe "#save_recent_counts" do
    let!(:stat_counter) { StatCounter.create(work_id: work_id, hit_count: 3) }

    it "updates the stat counters from redis" do
      hit_counter.redis.hset("recent_counts", work_id, 10)
      hit_counter.save_recent_counts

      expect(stat_counter.reload.hit_count).to eq(13)
    end

    it "clears the recent counts hash" do
      hit_counter.redis.hset("recent_counts", work_id, 10)
      hit_counter.save_recent_counts

      expect(hit_counter.redis.hgetall("recent_counts")).to \
        eq({})
    end
  end

  describe "#remove_outdated_keys" do
    it "removes information from previous days" do
      Delorean.time_travel_to "2020/01/30 2:59 UTC" do
        hit_counter.add(work_id, ip_address)

        expect(hit_counter.redis.exists("#{work_id}:20200129")).to be_truthy
        expect(hit_counter.redis.hgetall("keys")).to \
          eq({ "#{work_id}:20200129" => "20200129" })
      end

      Delorean.time_travel_to "2020/01/30 3:01 UTC" do
        hit_counter.remove_outdated_keys

        expect(hit_counter.redis.exists("#{work_id}:20200129")).to be_falsey
        expect(hit_counter.redis.hgetall("keys")).to \
          eq({})
      end
    end

    it "doesn't remove information from the current day" do
      Delorean.time_travel_to "2020/01/30 2:59 UTC" do
        hit_counter.add(work_id, ip_address)
      end

      Delorean.time_travel_to "2020/01/30 3:01 UTC" do
        hit_counter.add(work_id, ip_address)
      end

      Delorean.time_travel_to "2020/01/30 3:02 UTC" do
        hit_counter.remove_outdated_keys

        expect(hit_counter.redis.exists("#{work_id}:20200129")).to be_falsey
        expect(hit_counter.redis.exists("#{work_id}:20200130")).to be_truthy
        expect(hit_counter.redis.hgetall("keys")).to \
          eq({ "#{work_id}:20200130" => "20200130" })
      end
    end

    it "doesn't modify recent_counts" do
      Delorean.time_travel_to "2020/01/30 2:59 UTC" do
        hit_counter.add(work_id, ip_address)
      end

      Delorean.time_travel_to "2020/01/30 3:01 UTC" do
        hit_counter.add(work_id, ip_address)
      end

      Delorean.time_travel_to "2020/01/30 3:02 UTC" do
        expect do
          hit_counter.remove_outdated_keys
        end.not_to(change { hit_counter.redis.hgetall("recent_counts") })
      end
    end
  end
end
