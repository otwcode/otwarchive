# ES UPGRADE TRANSITION #
# Change all instances of $new_elasticsearch to $elasticsearch

# ES UPGRADE TRANSITION #
# Remove method
def elasticsearch_enabled?(elasticsearch_instance)
  elasticsearch_instance.cluster.health rescue nil
end

# ES UPGRADE TRANSITION #
# Remove method
def tire_update(klass_name)
  klass = klass_name.capitalize.constantize

  Tire.index(klass.index_name).delete
  klass.create_elasticsearch_index

  klass.import
  klass.tire.index.refresh
end

def es_update(klass)
  index_name = "ao3_test_#{klass.to_s.downcase}s"

  if $new_elasticsearch.indices.exists? index: index_name
    $new_elasticsearch.indices.delete index: index_name
  end

  indexer_class = "#{klass.capitalize}Indexer".constantize

  indexer_class.create_index

  if klass == 'bookmark'
    bookmark_indexers = {
      BookmarkedExternalWorkIndexer => ExternalWork,
      BookmarkedSeriesIndexer => Series,
      BookmarkedWorkIndexer => Work
    }

    bookmark_indexers.each do |indexer, bookmarkable|
      indexer.new(bookmarkable.all.pluck(:id)).index_documents if bookmarkable.any?
    end
  end

  indexer = indexer_class.new(klass.capitalize.constantize.all.pluck(:id))
  indexer.index_documents rescue nil

  $new_elasticsearch.indices.refresh index: "ao3_test_#{klass}s"
end
