require "cucumber/rspec/doubles"

Given /^the (\w+) indexes are completely regenerated$/ do |klass|
  es_update(klass)
end

Given /^all search indexes are completely regenerated$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |klass|
    step %{the #{klass} indexes are completely regenerated}
  end
end

Given /^the (\w+) indexes are refreshed$/ do |model|
  $elasticsearch.indices.refresh index: "ao3_test_#{model}s"
end

Given /^all search indexes are refreshed$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |model|
    step %{the #{model} indexes are refreshed}
  end
end

Given /^the (\w+) indexing job has been run$/ do |reindex_type|
  ScheduledReindexJob.perform(reindex_type)
  step %{all search indexes are refreshed}
end

Given /^all indexing jobs have been run$/ do
  %w(main background stats).each do |reindex_type|
    step %{the #{reindex_type} indexing job has been run}
  end
end

Given /^the max search result count is (\d+)$/ do |max|
  stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
  ArchiveConfig.MAX_SEARCH_RESULTS = max.to_i
end

Given /^(\d+) item(?:s)? (?:is|are) displayed per page$/ do |per_page|
  stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
  ArchiveConfig.ITEMS_PER_PAGE = per_page.to_i
end

Given /^(\d+) tag(?:s)? (?:is|are) displayed per search page$/ do |per_page|
  stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
  ArchiveConfig.TAGS_PER_SEARCH_PAGE = per_page.to_i
end
