namespace :tags do
  desc "Reset unique bookmark tags to 'Unsorted' (AO3-7294)"
  task reset_bookmark_only: :environment do
    # We search for tags that are not official, are not synonyms, and do not have related works, but have associations (parents) or categorized types.
    scope = Tag.nonsynonymous.where(taggings_count_cache: 0)
               .where("type != 'Tag' OR id IN (SELECT common_tag_id FROM common_taggings)")

    puts "Tags found for cleaning: #{scope.count}"

    scope.find_each(batch_size: 1000) do |tag|
      # Removes data from the association table (Wrangling)
      tag.common_taggings.delete_all 
      
      # Return the type to 'Tag' (status 'Unsorted')
      tag.update_column(:type, 'Tag')
    end

    puts "Cleaning complete."
  end
end