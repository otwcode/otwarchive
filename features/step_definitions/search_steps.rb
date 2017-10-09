Given /^the (\w+) indexes are updated$/ do |klass|
  es_update(klass)
  # ES UPGRADE TRANSITION #
  # Remove unless block
  unless !elasticsearch_enabled?($elasticsearch)
    tire_update(klass)
  end
end


Given /^all search indexes are updated$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |klass|
    step %{the #{klass} indexes are updated}
  end
end

Given /^the (\w+) indexes are reindexed$/ do |model|
  # ES UPGRADE TRANSITION #
  # Change $new_elasticsearch to $elasticsearch
  $new_elasticsearch.indices.refresh index: "ao3_test_#{model}s"
end

Given /^all search indexes are reindexed$/ do
  ['work', 'bookmark', 'pseud', 'tag'].each do |model|
    step %{the #{model} indexes are reindexed}
  end
end
