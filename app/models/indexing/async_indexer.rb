class AsyncIndexer

  BATCH_SIZE = 1000
  attr_reader :klass, :options

  def initialize(klass, options={})
    @klass = klass
    @options = options
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
    return unless REDIS_GENERAL.exists(old_queue_name)
    REDIS_GENERAL.rename(old_queue_name, queue_name)
    ids = REDIS_GENERAL.smembers(queue_name)
    ids.in_groups_of(BATCH_SIZE).each_with_index do |id_batch, i|
      subset_key = "#{queue_name}_#{i}"
      REDIS_GENERAL.sadd(subset_key, id_batch)
      enqueue_subset(subset_key)
    end
    REDIS_GENERAL.del(queue_name)
  end

  def enqueue_subset(key)
    queue = case options[:label].to_s
            when 'stats'
              :reindex_stats
            when 'background'
              :reindex_low
            else
              :reindex_high
            end
    job_class = "#{self.klass}ReindexJob".constantize
    Resque::Job.create(queue, job_class, key)
  end

  def run_subset(key)
    ids = REDIS_GENERAL.smembers(key)
    if perform_batch_update(ids) == 200
      REDIS_GENERAL.del(key)
    else
      REDIS_GENERAL.rename(key, "#{key}_DEAD")
    end
  end

  def perform_batch_update(ids)
    objects = klass.where(id: ids).group_by(&:id)
    @batch = []
    ids.each { |id| add_to_batch(id, (objects[id.to_i] || []).first) }
    response = ElasticsearchSimpleClient.send_batch(@batch)
    case response.code
    when 200
      klass.successful_reindex(ids)
    else
      log.info(response.inspect)
    end
    response.code
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
