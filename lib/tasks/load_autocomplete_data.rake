require 'radix'

namespace :autocomplete do
  
  desc "Clear autocomplete data"
  task(:clear_autocomplete_data => :environment) do
    keys = $redis.keys("autocomplete_*")
    $redis.del(*keys)
    puts "Cleared all autocomplete data"
  end
  
  desc "Reload tags and pseuds into Redis autocomplete"
  task(:reload_autocomplete_data => [:reload_autocomplete_tag_data, :reload_autocomplete_pseud_data, :reload_autocomplete_collection_data, :reload_autocomplete_tagset_data]) do
    puts "Reloaded autocomplete data"
  end
  
  desc "Clear tag data"
  task(:clear_autocomplete_tag_data => :environment) do
    keys = $redis.keys("autocomplete_tag_*") + $redis.keys("autocomplete_fandom_*")
    $redis.del(*keys)
  end

  desc "Clear tagset data"
  task(:clear_autocomplete_tagset_data => :environment) do
    keys = $redis.keys("autocomplete_tagset_*")
    $redis.del(*keys)
  end

  desc "Clear pseud data"
  task(:clear_autocomplete_pseud_data => :environment) do
    keys = $redis.keys("autocomplete_pseud_*")
    $redis.del(*keys)
  end
  
  desc "Clear collection data"
  task(:clear_autocomplete_collection_data => :environment) do
    keys = $redis.keys("autocomplete_collection_*")
    $redis.del(*keys)
  end
  
  desc "Reload tag data into Redis for autocomplete"
  task(:reload_autocomplete_tag_data => :environment) do
    (Tag::TYPES - ['Banned']).each do |type|
      query = type.constantize.canonical
      query = query.includes(:parents) if type == "Character" || type == "Relationship"
      query.each do |tag|
        tag.add_to_redis
      end
    end    
  end
  
  desc "Reload pseud data into Redis for autocomplete"
  task(:reload_autocomplete_pseud_data => :environment) do
    Pseud.not_orphaned.includes(:user).each do |pseud|
      pseud.add_to_redis
    end    
  end

  desc "Reload collection data into Redis for autocomplete"
  task(:reload_autocomplete_collection_data => :environment) do
    Collection.with_item_count.includes(:collection_preference).each do |collection|
      collection.add_to_redis(collection.item_count)
    end
  end


  desc "Reload tagsets into Redis"
  task(:reload_autocomplete_tagset_data => :environment) do
    TagSet.all.each do |tag_set|
      key = "autocomplete_tagset_#{tag_set.id}"
      tag_set.tags.each do |tag|
        $redis.zadd(key, 0, tag.name)
      end
    end
  end

end
