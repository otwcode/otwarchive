require "spec_helper"

describe RedisHitCounter do
  let(:work_id) { 42 }
  let(:ip_address) { Faker::Internet.ip_v4_address }

  describe ".current_timestamp" do
    it "returns the previous date at 2:59 AM UTC" do
      travel_to "2020-01-30 02:59:00 UTC" do
        expect(RedisHitCounter.current_timestamp).to eq("20200129")
      end
    end

    it "returns the current date at 3:00 AM UTC" do
      travel_to "2020-01-30 03:00:00 UTC" do
        expect(RedisHitCounter.current_timestamp).to eq("20200130")
      end
    end

    it "returns the current date at 3:01 AM UTC" do
      travel_to "2020-01-30 03:01:00 UTC" do
        expect(RedisHitCounter.current_timestamp).to eq("20200130")
      end
    end
  end

  describe ".add" do
    context "when the IP address hasn't visited" do
      it "records the IP address and increments the count" do
        travel_to "2020-01-30 03:05:00 UTC" do
          RedisHitCounter.add(work_id, ip_address)
        end

        expect(RedisHitCounter.redis.smembers("visits:20200130")).to \
          eq(["#{work_id}:#{ip_address}"])
        expect(RedisHitCounter.redis.hgetall("recent_counts")).to \
          eq(work_id.to_s => "1")
      end
    end

    context "when the IP address has already visited after 3 AM" do
      before do
        travel_to "2020-01-30 03:01:00 UTC" do
          RedisHitCounter.add(work_id, ip_address)
        end

        RedisHitCounter.redis.del("recent_counts")
      end

      it "doesn't increment the count" do
        travel_to "2020-01-30 03:02:00 UTC" do
          RedisHitCounter.add(work_id, ip_address)
        end

        expect(RedisHitCounter.redis.hgetall("recent_counts")).to \
          eq({})
      end
    end

    context "when the IP address has already visited before 3 AM" do
      before do
        travel_to "2020-01-30 02:59:00 UTC" do
          RedisHitCounter.add(work_id, ip_address)
        end

        RedisHitCounter.redis.del("recent_counts")
      end

      it "increments the count" do
        travel_to "2020-01-30 03:02:00 UTC" do
          RedisHitCounter.add(work_id, ip_address)
        end

        expect(RedisHitCounter.redis.hgetall("recent_counts")).to \
          eq(work_id.to_s => "1")
      end
    end
  end

  describe ".remove_old_visits" do
    it "removes information from previous days" do
      travel_to "2020-01-30 02:59:00 UTC" do
        RedisHitCounter.add(work_id, ip_address)

        expect(RedisHitCounter.redis.exists("visits:20200129")).to be_truthy
      end

      travel_to "2020-01-30 03:01:00 UTC" do
        RedisHitCounter.remove_old_visits

        expect(RedisHitCounter.redis.exists("visits:20200129")).to be_falsey
      end
    end

    it "doesn't remove information from the current day" do
      travel_to "2020-01-30 02:59:00 UTC" do
        RedisHitCounter.add(work_id, ip_address)
      end

      travel_to "2020-01-30 03:01:00 UTC" do
        RedisHitCounter.add(work_id, ip_address)
      end

      travel_to "2020-01-30 03:02:00 UTC" do
        RedisHitCounter.remove_old_visits

        expect(RedisHitCounter.redis.exists("visits:20200129")).to be_falsey
        expect(RedisHitCounter.redis.exists("visits:20200130")).to be_truthy
      end
    end

    it "doesn't modify recent_counts" do
      travel_to "2020-01-30 02:59:00 UTC" do
        RedisHitCounter.add(work_id, ip_address)
      end

      travel_to "2020-01-30 03:01:00 UTC" do
        RedisHitCounter.add(work_id, ip_address)
      end

      travel_to "2020-01-30 03:02:00 UTC" do
        expect do
          RedisHitCounter.remove_old_visits
        end.not_to(change { RedisHitCounter.redis.hgetall("recent_counts") })
      end
    end
  end
end
