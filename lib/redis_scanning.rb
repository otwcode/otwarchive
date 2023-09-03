module RedisScanning
  def scan_set_in_batches(redis, key, batch_size:, &block)
    redis.sscan_each(key, count: batch_size).each_slice(batch_size, &block)
  end

  def scan_hash_in_batches(redis, key, batch_size:, &block)
    redis.hscan_each(key, count: batch_size).each_slice(batch_size) do |batch|
      block.call(batch.to_h)
    end
  end
end
