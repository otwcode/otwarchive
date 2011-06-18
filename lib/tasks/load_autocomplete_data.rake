namespace :autocomplete do
  
  # we need to delete the keys in batches to avoid stack level too deep error
  KEYSLICE_SIZE = 10000
  
  desc "Clear autocomplete data"
  task(:clear_data => :environment) do
    keys = $redis.keys("autocomplete_*")
    keys.each_slice(KEYSLICE_SIZE) {|keyslice| $redis.del(*keyslice)}
    puts "Cleared all autocomplete data"
  end

  desc "Load data into Redis for autocomplete"
  task(:load_data => [:load_tag_data, :load_pseud_data, :load_collection_data, :load_tagset_data]) do
    puts "Loaded all autocomplete data"
  end
  
  desc "Clear and reload data into Redis for autocomplete"
  task(:reload_data => [:clear_data, :load_data]) do
    puts "Finished reloading"
  end
  
  desc "Clear tag data"
  task(:clear_tag_data => :environment) do
    keys = $redis.keys("autocomplete_tag_*") + $redis.keys("autocomplete_fandom_*")
    keys.each_slice(KEYSLICE_SIZE) {|keyslice| $redis.del(*keyslice)}
  end

  desc "Clear tagset data"
  task(:clear_tagset_data => :environment) do
    keys = $redis.keys("autocomplete_tagset_*")
    keys.each_slice(KEYSLICE_SIZE) {|keyslice| $redis.del(*keyslice)}
  end

  desc "Clear pseud data"
  task(:clear_pseud_data => :environment) do
    keys = $redis.keys("autocomplete_pseud_*")
    keys.each_slice(KEYSLICE_SIZE) {|keyslice| $redis.del(*keyslice)}
  end
  
  desc "Clear collection data"
  task(:clear_collection_data => :environment) do
    keys = $redis.keys("autocomplete_collection_*")
    keys.each_slice(KEYSLICE_SIZE) {|keyslice| $redis.del(*keyslice)}
  end
  
  desc "Load tag data into Redis for autocomplete"
  task(:load_tag_data => :environment) do
    (Tag::TYPES - ['Banned']).each do |type|
      query = type.constantize.canonical
      query = query.includes(:parents) if type == "Character" || type == "Relationship"
      query.each do |tag|
        tag.add_to_autocomplete
      end
    end    
  end
  
  desc "Load pseud data into Redis for autocomplete"
  task(:load_pseud_data => :environment) do
    Pseud.not_orphaned.includes(:user).each do |pseud|
      pseud.add_to_autocomplete
    end    
  end

  desc "Load collection data into Redis for autocomplete"
  task(:load_collection_data => :environment) do
    Collection.with_item_count.includes(:collection_preference).each do |collection|
      collection.add_to_autocomplete(collection.item_count)
    end
  end


  desc "Load tagsets into Redis"
  task(:load_tagset_data => :environment) do
    # we only load tagsets used in challenge settings, not ones used in
    # individual signups
    PromptRestriction.all.each do |restriction|
      tag_set = restriction.tag_set
      key = "autocomplete_tagset_#{tag_set.id}"
      tag_set.tags.each do |tag|
        $redis.zadd(key, 0, tag.name)
      end
    end
  end

  desc "Clear and reload tag data into Redis for autocomplete"
  task(:reload_tag_data => [:clear_tag_data, :load_tag_data]) do
    puts "Finished reloading tags"
  end

  desc "Clear and reload pseud data into Redis for autocomplete"
  task(:reload_pseud_data => [:clear_pseud_data, :load_pseud_data]) do
    puts "Finished reloading pseuds"
  end

  desc "Clear and reload collection data into Redis for autocomplete"
  task(:reload_collection_data => [:clear_collection_data, :load_collection_data]) do
    puts "Finished reloading collections"
  end

  desc "Clear and reload tagset data into Redis for autocomplete"
  task(:reload_tagset_data => [:clear_tagset_data, :load_tagset_data]) do
    puts "Finished reloading tagsets"
  end

end
