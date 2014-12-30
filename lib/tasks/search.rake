namespace :search do
  desc "Reindex tags"
  task(:index_tags => :environment) do
    TagIndexer.index_all
  end
  desc "Reindex pseuds"
  task(:index_pseuds => :environment) do
    PseudIndexer.index_all
  end
  desc "Reindex works"
  task(:index_works => :environment) do
    WorkIndexer.index_all
  end
  desc "Reindex bookmarks"
  task(:index_bookmarks => :environment) do
    BookmarkIndexer.index_all
  end
end