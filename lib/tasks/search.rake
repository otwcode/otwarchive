namespace :search do
  desc "Reindex tags"
  task(:index_tags => :environment) do
    ES::TagIndexer.index_all
  end
  desc "Reindex pseuds"
  task(:index_pseuds => :environment) do
    ES::PseudIndexer.index_all
  end
  desc "Reindex works"
  task(:index_works => :environment) do
    ES::WorkIndexer.index_all
  end
  desc "Reindex bookmarks"
  task(:index_bookmarks => :environment) do
    ES::BookmarkIndexer.index_all
  end
end