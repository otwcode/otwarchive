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

  indexer = indexer_class.new(klass.capitalize.constantize.all.pluck(:id))
  indexer.index_documents rescue nil

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

  $new_elasticsearch.indices.refresh index: "ao3_test_#{klass}s"
end

Given /^the (\w+) indexes are updated$/ do |klass|
  es_update(klass)
  # @es_version.match('0.90') ? tire_update(klass) : es_update(klass)
end


Given /^all search indexes are updated$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |klass|
    step %{the #{klass} indexes are updated}
  end
end

Given /^the (\w+) indexes are reindexed$/ do |model|
  $new_elasticsearch.indices.refresh index: "ao3_test_#{model}s"
end

Given /^all search indexes are reindexed$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |model|
    step %{the #{model} indexes are reindexed}
  end
end
