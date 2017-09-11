Given /^all search indexes are updated$/ do
  [Work, Bookmark, Pseud, Tag].each do |klass|
    # TIRE
    # klass.import
    # klass.tire.index.refresh
    #
    # Elasticsearch
    if $elasticsearch.indices.exists? index: "ao3_test_#{klass.to_s.downcase}s"
      $elasticsearch.indices.delete index: "ao3_test_#{klass.to_s.downcase}s"
    end

    "#{klass}Indexer".constantize.create_index

    indexer = "#{klass}Indexer".constantize.new(klass.all.pluck(:id))
    indexer.index_documents rescue nil
  end
end

Given /^the (\w+) indexes are updated$/ do |model|
  # TIRE
  # model.classify.constantize.import
  # model.classify.constantize.tire.index.refresh
  #
  # Elasticsearch
  if $elasticsearch.indices.exists? index: "ao3_test_#{model}s"
    $elasticsearch.indices.delete index: "ao3_test_#{model}s"
  end

  "#{model.classify}Indexer".constantize.create_index

  indexer = "#{model.classify}Indexer".constantize.new(model.classify.constantize.all.pluck(:id))
  indexer.index_documents if model.classify.constantize.any?

  if model == 'bookmark'
    BookmarkedExternalWorkIndexer.new(ExternalWork.all.pluck(:id)).index_documents if ExternalWork.any?
    BookmarkedSeriesIndexer.new(Series.all.pluck(:id)).index_documents if Series.any?
    BookmarkedWorkIndexer.new(Work.all.pluck(:id)).index_documents if Work.any?
  end
end

Given /^the (\w+) indexes are reindexed$/ do |model|
  $elasticsearch.indices.refresh index: "ao3_test_#{model}s"
end

Given /^all search indexes are reindexed$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |model|
    step %{the #{model} indexes are reindexed}
  end
end
