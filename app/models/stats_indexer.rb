class StatsIndexer < AsyncIndexer

  def initialize(klass)
    @klass = klass
    raise "The stats indexer is only for works!" unless klass == Work
  end

  def old_queue_name
    "search_index_work_stats"
  end

  def new_queue_name
    "#{old_queue_name}_#{Time.now.to_i}"
  end

  def perform_batch_update(ids)
    objects = StatCounter.where(work_id: ids).group_by(&:work_id)
    @batch = []
    ids.each { |id| add_to_batch(id, (objects[id] || []).first) }
    ElasticsearchSimpleClient.send_batch(@batch)
  end

  def add_to_batch(id, obj)
    basics = { "_index" => klass.index_name, "_type" => klass.document_type, "_id" => id}
    unless obj.nil?
      @batch << { update: basics }.to_json
      @batch << { 
        doc: { 
          hits: obj.hit_count,
          kudos_count: obj.kudos_count, 
          bookmarks_count: obj.bookmarks_count, 
          comments_count: obj.comments_count
        } 
      }.to_json
    end
  end

end