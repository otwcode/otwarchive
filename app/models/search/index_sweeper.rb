class IndexSweeper

  REDIS = AsyncIndexer::REDIS

  def self.async_cleanup(klass, expected_ids, found_ids)
    deleted_ids = expected_ids.map(&:to_i).select { |id| !found_ids.include?(id) }

    if deleted_ids.any?
      AsyncIndexer.index(klass, deleted_ids, "cleanup")
    end
  end

  def initialize(batch, indexer)
    @batch = batch
    @indexer = indexer
    @rerun_ids = []

    ensure_failure_stores
  end

  def process_batch_failures
    return if !@batch["errors"] && all_stores_empty?

    @batch["items"].each do |item|
      process_document_failures(item)
    end

    AsyncIndexer.new(@indexer, "failures").enqueue_ids(@rerun_ids) unless @rerun_ids.empty?
  end

  def process_document_failures(item)
    document = item[item.keys.first] # update/index/delete
    document_stamp = { document["_id"].to_s => document["error"] }

    first_store = get_store_as_json "first"
    second_store = get_store_as_json "second"
    permanent_store = get_store_as_json "permanent"

    if !document["error"]
      [first_store, second_store, permanent_store].each do |raw_store|
         raw_store.select  { |doc| doc.keys.first == document["_id"] }.each do |doc|
           raw_store.delete(doc)
         end
       end

      set_store "first", first_store
      set_store "second", second_store
      set_store "permanent", permanent_store

      return
    end

    return if permanent_store.include?(document_stamp)

    if first_store.include?(document_stamp)
      second_store << document_stamp
      first_store.delete(document_stamp)
      set_store "second", second_store
      set_store "first", first_store
      @rerun_ids << document["_id"]
    elsif second_store.include?(document_stamp)
      permanent_store << document_stamp
      second_store.delete(document_stamp)
      set_store "permanent", permanent_store
      set_store "second", second_store
    else
      first_store << document_stamp
      set_store "first", first_store
      @rerun_ids << document["_id"]
    end
  end

  private

  def ensure_failure_stores
    ["first",
     "second",
     "permanent"].each do |store_name|
      unless REDIS.get("#{@indexer}:#{store_name}_failure_store")
        set_store store_name, []
      end
    end
  end

  def all_stores_empty?
    get_store_as_json("first").empty? &&
      get_store_as_json("second").empty? &&
      get_store_as_json("permanent").empty?
  end

  def set_store(store_name, raw_store)
    REDIS.set("#{@indexer}:#{store_name}_failure_store", raw_store.to_json)
  end

  def get_store_as_json(store_name)
    JSON.parse(REDIS.get("#{@indexer}:#{store_name}_failure_store"))
  end

end
