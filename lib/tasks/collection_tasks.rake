namespace :collection do
  desc "determines all unique fandoms for collection and their subcollections and convert them to tags"
  task(create_tags: :environment) do
    @collections = Collection.all
    
    @collections.each do |collection|
      collections_bookmarks = collection.all_approved_bookmarks
      bookmarkables = collections_bookmarks.map(&:bookmarkable).uniq
      tags = bookmarkables.map(&:direct_filters).flatten.uniq

      next if tags.empty? || tags.length > ArchiveConfig.COLLECTION_TAGS_MAX

      # create tags for all existing fandoms
      collection.tags << tags

      # check if collection is multifandom
      crossover = FandomCrossover.new.check_for_crossover(tags)
      collection.update(multifandom: crossover) if crossover == true

      puts "Converted collection #{collection.name} fandoms to tags"
    end
  end
end
