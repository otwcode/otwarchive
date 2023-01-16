module RedisScanning
  def scan_set_in_batches(redis, key, batch_size:)
    cursor = "0"

    loop do
      cursor, batch = redis.sscan(key, cursor, count: batch_size)
      yield batch unless batch.empty?
      break if cursor == "0"
    end
  end
end
