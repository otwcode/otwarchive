namespace :search do
  desc "Reindex tags"
  task(:index_tags => :environment) do
    ES::TagIndexer.index_all
  end
end