class AsyncIndexer

  BATCH_SIZE = 1000
  attr_reader :klass

  def initialize(klass, options={})
    @klass = klass
  end

  def log
    @@log ||= Logger.new("#{Rails.root}/log/index-errors.log")
  end

  def old_queue_name
    name = "search_index_#{klass.to_s.underscore}"
    if options[:label].present?
      name << "_#{options[:label]}"
    end
    name
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
    ids.each { |id| add_to_batch(id, (objects[id.to_i] || []).first) }
    response = ElasticsearchSimpleClient.send_batch(@batch)
    case response.code
    when 200
      klass.successful_reindex(ids, queue_name)
    else
      log.info(response.inspect)
    end
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
