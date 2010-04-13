namespace :After do

  ##################################################################
  # LEAVE THIS SECTION ALONE -- turns off TS deltas and turns them back on 
  # after all migrate tasks are run
  desc "Turn off thinking sphinx deltas"
  task(:turn_off_deltas => :environment) do
    puts "Disabling Thinking Sphinx updates while we migrate..."
    ThinkingSphinx.deltas_enabled=false
  end
  
  desc "Turn on thinking sphinx deltas"
  task(:turn_on_deltas => :environment) do
    ThinkingSphinx.deltas_enabled=true
    puts "Re-enabled Thinking Sphinx updates"
  end

  # top_level_tasks isn't writable so we need to do this 
  # instance_variable_set hack to prepend/append the delta
  # tasks when the After tasks are run
  current_tasks =  Rake.application.top_level_tasks
  if current_tasks.first && current_tasks.first.match(/After/)
    current_tasks.unshift('After:turn_off_deltas')
    current_tasks << 'After:turn_on_deltas'
    Rake.application.instance_variable_set(:@top_level_tasks, current_tasks)
  end
  ###################################################################


# everything commented out has already been run on the archive...
# keeping only the most recent tasks - if you need to go back further, check subversion
  
#  desc "Fix warning tags"
#  task(:fix_warnings => :environment) do
#    good_tag = Warning.find_by_name("Rape/Non-Con")
#    bad_tag = Warning.find_by_name("Rape/Non Con")
#    if good_tag && bad_tag
#      # First make them synonyms so that the works get the good tag as a filter
#      bad_tag.merger = good_tag
#      bad_tag.save!
#      # Then just move all the taggings to the right tag
#      Tagging.update_all("tagger_id = #{good_tag.id}", "tagger_id = #{bad_tag.id}")
#      bad_tag.reload
#      if bad_tag.taggings.count == 0
#        bad_tag.destroy
#      else
#        raise "Something went wrong with the warning tags"
#      end
#    end
#    violence_tag = Warning.find_by_name(ArchiveConfig.WARNING_VIOLENCE_TAG_NAME)
#    if violence_tag && violence_tag.name != ArchiveConfig.WARNING_VIOLENCE_TAG_NAME
#      violence_tag.update_attribute(:name, ArchiveConfig.WARNING_VIOLENCE_TAG_NAME)
#    end
#  end 
#
#  desc "Clear up wrangling relationships"
#  task(:tidy_wranglings => :environment) do
#    [Character, Pairing, Freeform].each do |klass|
#      puts "Updating #{klass.to_s.downcase.pluralize}"
#      klass.by_name.find(:all, :conditions => "fandom_id IS NOT NULL").each do |tag|
#        begin
#          puts tag.name
#          if tag.fandom && !tag.fandoms.include?(tag.fandom)
#            tag.fandoms << tag.fandom
#          end
#        rescue
#          puts "Something went wrong with #{tag.name}!"
#        end
#      end
#    end
#    Fandom.by_name.each do |tag|
#      begin
#        puts tag.name
#        if tag.media_id && tag.media && !tag.medias.include?(tag.media)
#          tag.parents << tag.media
#        end
#        if tag.medias.empty?
#          tag.parents << Media.uncategorized          
#        end
#      rescue
#        puts "Something went wrong with #{tag.name}!"        
#      end
#    end
#  end
#  
#  desc "Remove invalid synonyms from canonical tags"
#  task(:exorcise_syns => :environment) do
#    tags = Tag.canonical.find(:all, :conditions => "merger_id IS NOT NULL")
#    tags.each { |tag| tag.update_attribute(:merger_id, nil) }
#  end  
#  
#  desc "Clean up invites belonging to deleted users"
#  task(:deleted_invites_cleanup => :environment) do
#    UserInviteRequest.all.each do |user_invite_request|
#      if user_invite_request.user.nil?
#        user_invite_request.destroy
#      end
#    end
#  end
#
# desc "Map gifts to pseuds where that is feasible"
# task(:map_gifts => :environment) do
#   gifts = Gift.find(:all)
#   gifts.each do |gift|
#     puts "Setting recipient for gift to #{gift.recipient_name}"
#     gift.recipient = gift.recipient_name
#     gift.save
#   end
# end
# 
# desc "Clean up related works that are connected to deleted works"
# task(:related_work_cleanup => :environment) do
#   RelatedWork.all.each do |rw| 
#     unless rw.parent && rw.work
#       rw.destroy
#     end
#   end
# end
# 


  #### Add your new tasks here

end # this is the end that you have to put new tasks above

##################
# ADD NEW MIGRATE TASKS TO THIS LIST ONCE THEY ARE WORKING

# Remove tasks from the list once they've been run on the deployed site
desc "Run all current migrate tasks"
#task :After => ['After:fix_warnings', 'After:tidy_wranglings', 'After:exorcise_syns', 'After:deleted_invites_cleanup']
task :After => []