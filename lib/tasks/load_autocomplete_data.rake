namespace :autocomplete do
  
  desc "Clear autocomplete data"
  task(:clear_autocomplete_data => :environment) do
    keys = $redis.keys("autocomplete_*")
    $redis.del(*keys)
    puts "Cleared all autocomplete data"
  end
  
  desc "Reload tags and pseuds into Redis autocomplete"
  task(:reload_autocomplete_data => [:reload_autocomplete_tag_data, :reload_autocomplete_pseud_data, :reload_autocomplete_collection_data, :reload_autocomplete_tagset_data]) do
    puts "Reloaded tag and pseud data"
  end
  
  desc "Clear tag data"
  task(:clear_autocomplete_tag_data => :environment) do
    keys = $redis.keys("autocomplete_tag_*")
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
    # load up canonical user-defined tags
    Tag::USER_DEFINED.each do |type|
      type.classify.constantize.visible_to_all_with_count.each do |tag|
        score = tag.count
        tag.name.three_letter_sections.each do |section|
          key = "autocomplete_tag_#{type.downcase}_#{section}"
          # score is the number of uses of the tag on public works
          $redis.zadd(key, score, tag.name)
        end
      end
    end    
  end
  
  desc "Reload pseud data into Redis for autocomplete"
  task(:reload_autocomplete_pseud_data => :environment) do
    Pseud.not_orphaned.each do |pseud|
      pseud.add_to_autocomplete
    end    
  end

  desc "Reload collection data into Redis for autocomplete"
  task(:reload_autocomplete_collection_data => :environment) do
    Collection.all.each do |collection|
      collection.add_to_autocomplete
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
