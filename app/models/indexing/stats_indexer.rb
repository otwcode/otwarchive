class StatsIndexer < AsyncIndexer

  def options
    @options[:label] = :stats
    @options
  end

  def add_to_batch(id, obj)
    basics = { "_index" => Work.index_name, "_type" => Work.document_type, "_id" => obj.work_id}
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