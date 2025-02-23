# A job to index the record IDs queued up by AsyncIndexer.
class AsyncIndexerJob < ApplicationJob
  REDIS = AsyncIndexer::REDIS

  def perform(name)
    indexer = name.split(":").first.constantize
    ids = REDIS.smembers(name)

    return if ids.empty?

    batch = indexer.new(ids).index_documents
    IndexSweeper.new(batch, indexer).process_batch
    REDIS.del(name)
  end
end
