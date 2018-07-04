require "cucumber/rspec/doubles"

Given /^the (\w+) indexes are completely regenerated$/ do |klass|
  es_update(klass)

  # ES UPGRADE TRANSITION #
  # Remove unless block
  unless $rollout.active?(:stop_old_indexing)
    tire_update(klass)
  end
end

Given /^all search indexes are completely regenerated$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |klass|
    step %{the #{klass} indexes are completely regenerated}
  end
end

Given /^the (\w+) indexes are refreshed$/ do |model|
  # ES UPGRADE TRANSITION #
  # Change $new_elasticsearch to $elasticsearch
  $new_elasticsearch.indices.refresh index: "ao3_test_#{model}s"

  # ES UPGRADE TRANSITION #
  # Remove unless block
  unless $rollout.active?(:stop_old_indexing)
    klass = model.capitalize.constantize
    klass.tire.index.refresh
  end
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

Given /^(\d+) items are displayed per page$/ do |per_page|
  stub_const("ArchiveConfig", OpenStruct.new(ArchiveConfig))
  ArchiveConfig.ITEMS_PER_PAGE = per_page.to_i
end

When /^(\w+) can use the new search/ do |login|
  user = User.find_by(login: login)
  $rollout.activate_user(:use_new_search, user)
end
