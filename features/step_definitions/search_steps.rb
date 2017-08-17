Given /^all search indexes are updated$/ do
  [Work, Bookmark, Pseud, Tag].each do |klass|
    # TIRE
    # klass.import
    # klass.tire.index.refresh
    #
    # Elasticsearch
    indexer = "#{klass}Indexer".constantize.new(klass.all.pluck(:id))
    indexer.index_documents
  end
end

Given /^the (\w+) indexes are updated$/ do |model|
  # TIRE
  # model.classify.constantize.import
  # model.classify.constantize.tire.index.refresh
  #
  # Elasticsearch
  indexer = "#{model.classify}Indexer".constantize.new(model.classify.constantize.all.pluck(:id))
  indexer.index_documents
end

