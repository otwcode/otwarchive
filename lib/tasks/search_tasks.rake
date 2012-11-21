namespace :search do

  desc "Reindex works"
  task(:reindex_works => :environment) do
    RedisSearchIndexQueue.reindex_works
  end

  desc "Reindex bookmarks"
  task(:reindex_bookmarks => :environment) do
    RedisSearchIndexQueue.reindex_bookmarks
  end

  desc "Reindex all of elasticsearch"
  task(:reindex_all) do
    %q{/static/bin/reindex_elasticsearch.sh}
  end
end
