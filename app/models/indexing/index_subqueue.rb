class IndexSubqueue

  REDIS = REDIS_GENERAL

  ##################
  # CLASS METHODS
  ##################

  def self.create_and_enqueue(name, ids)
    self.new(name).add_ids(ids).enqueue
  end

  def self.perform(name)
    self.new(name).run
  end

  ####################
  # INSTANCE METHODS
  ####################  

  attr_reader :name

  def initialize(name)
    @name = name
    @batch = []
  end

  def add_ids(ids)
    REDIS.sadd(name, ids)
    self
  end

  def enqueue
    Resque::Job.create(reindex_queue, IndexSubqueue, name)
  end

  def run
    build_batch
    @response = perform_batch_update
    if @response.code == 200
      respond_to_success
    else
      respond_to_failure
    end
  end

  def log
    @@log ||= Logger.new("#{Rails.root}/log/index-errors.log")
  end 

  def ids
    @ids = REDIS.smembers(name).select{ |id| id.present? }
  end

  # private

  def objects
    @objects ||= klass.where(id: ids).group_by(&:id)
  end

  def klass
    name.split(':')[1].classify.constantize
  end

  def label
    name.split(':')[2]
  end

  def reindex_queue
    case label
    when 'main'
      :reindex_high
    when 'stats'
      :reindex_stats
    else
      :reindex_low
    end
  end
  
  def delete
    REDIS.del(name)
  end

  def build_batch
    ids.each { |id| add_to_batch(id, (objects[id.to_i] || []).first) }
  end

  def respond_to_success
    if klass.respond_to?(:successful_reindex)
      klass.successful_reindex(ids)
    end
    delete
  end

  def respond_to_failure
    log.info(@response.inspect)
    REDIS.rename(name, "#{name}:DEAD")
  end

  def perform_batch_update
    ElasticsearchSimpleClient.send_batch(@batch)
  end

  def add_to_batch(id, obj)
    case obj
    when nil
      add_deletion_to_batch(id)
    when StatCounter
      add_stats_to_batch(obj)
    else
      add_document_to_batch(obj)
    end
  end

  def add_document_to_batch(obj)
    basics = { "_index" => klass.index_name, "_type" => klass.document_type, "_id" => obj.id }
    @batch << { index: basics }.to_json
    @batch << obj.to_indexed_json
  end

  def add_deletion_to_batch(id)
    basics = { "_index" => klass.index_name, "_type" => klass.document_type, "_id" => id }
    @batch << { delete: basics }.to_json
  end

  def add_stats_to_batch(obj)
    basics = { "_index" => Work.index_name, "_type" => Work.document_type, "_id" => obj.work_id }
    @batch << { update: basics }.to_json
    @batch << { 
      doc: { 
        work: {
          hits: obj.hit_count,
          kudos_count: obj.kudos_count, 
          bookmarks_count: obj.bookmarks_count, 
          comments_count: obj.comments_count
        }
      } 
    }.to_json
  end

end
