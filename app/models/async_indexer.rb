class AsyncIndexer

  BATCH_SIZE = 1000
  attr_reader :klass

  def initialize(klass)
    @klass = klass
  end

  def old_queue_name
    "search_index_#{klass.to_s.underscore}"
  end

  def queue_name
    "#{old_queue_name}_#{Time.now.to_i}"
  end

  def perform
    REDIS_GENERAL.rename(old_queue_name, queue_name)
    ids = REDIS_GENERAL.smembers(queue_name)
    ids.in_groups_of(BATCH_SIZE) do |id_batch|
      perform_batch_update(id_batch)
    end
    REDIS_GENERAL.del(queue_name)
  end

  def perform_batch_update(ids)
    objects = klass.where(id: ids).group_by(&:id)
    @batch = []
    ids.each { |id| add_to_batch(id, (objects[id] || []).first) }
    ElasticsearchSimpleClient.send_batch(@batch)
  end

  def add_to_batch(id, obj)
    basics = { "_index" => klass.index_name, "_type" => klass.document_type, "_id" => id}
    if obj.nil?
      @batch << { delete: basics }.to_json
    else
      @batch << { index: basics }.to_json
      @batch << obj.to_indexed_json
    end
  end

end