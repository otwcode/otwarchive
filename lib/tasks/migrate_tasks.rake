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
  
#  # Need to run this again, there has been a bug which appears to have mysteriously been fixed
#   desc "Fix Series pseuds"
#   task(:after_r1501 => :environment) do
#     Series.all.each do |s|
#       unless s.works.empty?
#         s.works.map(&:pseuds).flatten.each do |p|
#           s.pseuds << p unless s.pseuds.include? p
#         end
#       end
#     end
#   end
# desc "Invitations changes"
# task(:after_20091018155535_add_columns_to_invitations => :environment) do
#  Invitation.all.each do |i|
#    if i.invitee_id
#      i.invitee_type = "ExternalAuthor"
#    elsif user = User.find_by_invitation_id(i.id)
#      i.invitee = user      
#    end
#    i.creator_type = "User" if i.creator_id
#    i.redeemed_at = i.updated_at if i.used?
#    i.save!
#  end
#end

#  desc "Set first_login to false for existing users"
#  task(:after_fix_first_login => :environment) do
#    Preference.update_all("first_login = 0")
#  end
#
#  desc "After r1721, clean up orphaned taggings"
#  task :clean_up_taggings => 'Tag:clean_up_taggings'
#  
  # Only running on posted works, since unposted works will eventually
  # be edited or deleted, and imported drafts may not be valid
#  desc "After r1728, fix works that lack revised at dates"
#  task(:fix_import_dates => :environment) do
#    ThinkingSphinx.deltas_enabled=false
#    Work.find(:all, :conditions => {:revised_at => nil, :posted => true}).each {|work| work.set_revised_at}
#    ThinkingSphinx.deltas_enabled=true
#  end

#  desc "Change Warning Tag name"
#  task(:after_change_warning_tag_name => :environment) do
#    @new = Warning.find_by_name('Choose Not To Warn')
#    @old = Warning.find_by_name('Choose Not To Warn For Some Content')
#    @none = Warning.find_by_name('None Of These Warnings Apply')
#    ThinkingSphinx.deltas_enabled=false
#    if @old && @new     
#      Tagging.update_all(["tagger_id = ?", @new.id], ["tagger_id = ?", @old.id])
#      FilterTagging.update_all(["filter_id = ?", @new.id], ["filter_id = ?", @old.id])
#      @new.reset_filter_count
#      # if the new tag name was turned into a new tag by the initializer, get rid of it
#      newest = Warning.find_by_name('Choose Not To Use Archive Warnings')
#      newest.destroy if newest
#      @new.update_attribute(:name, 'Choose Not To Use Archive Warnings')
#    end
#    @none.update_attribute(:name, 'No Archive Warnings Apply') if @none
#    ThinkingSphinx.deltas_enabled=true
#  end

#  desc "Follow-up to warning changes"
#  task(:warnings_follow_up => :environment) do
#    @new = Warning.find_by_name('Choose Not To Use Archive Warnings')
#    @old = Warning.find_by_name('Choose Not To Warn For Some Content')
#    ThinkingSphinx.deltas_enabled=false
#    if @old && @old.works.count == 0 && @old.filtered_works.count == 0
#      @old.destroy
#    else
#      raise "Something isn't right here! Double-check the first warnings rake task."
#    end
#    if @new
#      @new.update_attribute(:taggings_count, @new.taggings.count)
#    end
#    ThinkingSphinx.deltas_enabled=true
#  end

#  desc "Add missing filter counts"
#  task(:add_filter_counts => :environment) do
#    ThinkingSphinx.deltas_enabled=false
#    Fandom.canonical.find_each do |fandom|
#      unless fandom.filter_count
#        fandom.reset_filter_count
#        puts "Added filter count for #{fandom.name}"
#      end
#    end
#    ThinkingSphinx.deltas_enabled=true
#  end

  #### Add your new tasks here


  desc "Hide/anonymize existing collection items as appropriate"
  task(:update_collection_items => :environment) do
    puts "Hiding and anonymizing existing collection items"
    Collection.unrevealed.collect(&:collection_items).flatten.each {|ci| ci.unrevealed=true; ci.save}
    Collection.anonymous.collect(&:collection_items).flatten.each {|ci| ci.anonymous=true; ci.save}
  end

  desc "Rake task of DOOOOOOM: remove wrong filters"
  task(:remove_wrong_filters => :environment) do
    puts "Removing invalid filters"
    FilterTagging.remove_invalid
  end
  
  desc "Rake task of DOOOOOOM, Part 2: add missing filters"
  task(:add_missing_filters => :environment) do
    puts "Adding missing filters"
    Tag.add_missing_filter_taggings
  end
  
  desc "Rake task of DOOOOOOM, Part 3: reset all filter counts"
  task(:reset_counts => :environment) do
    puts "Resetting filter counts"
    FilterCount.set_all
  end
  
  desc "Fix for existing non-unique threads"  
  task(:fix_threads => :environment) do
    puts "Fixing duplicate threads"
    duplicate_threads = Comment.find(:all, :conditions => {:depth => 0}, :group => "thread HAVING count(thread) > 1", 
      :order => :thread, :select => :thread).collect(&:thread)
    Comment.find(:all, :conditions => {:thread => duplicate_threads}, :order => 'depth ASC').each do |comment|
      puts "Updating #{comment.id}"
      new_thread = comment.reply_comment? ? comment.commentable.thread : comment.id
      comment.update_attribute(:thread, new_thread)
    end  
  end
  
  desc "Set parent for comments"
  task(:add_comment_parents => :environment) do
    puts "Setting parent for all comments"
    max = Comment.maximum(:depth)
    (0..max).each do |i|
      puts "On depth #{i}!"
      Comment.find(:all, :conditions => {:depth => i}).each do |comment|
        if comment.commentable
          puts "Updating #{comment.id}"        
          comment.parent = (comment.depth == 0) ? comment.commentable : comment.commentable.parent
          comment.save
        else  
          puts "Comment #{comment.id} has no commentable!"
        end
      end      
    end    
  end  

end

##################
# ADD NEW MIGRATE TASKS TO THIS LIST ONCE THEY ARE WORKING

# Remove tasks from the list once they've been run on the deployed site
desc "Run all current migrate tasks"
task :After => ['After:update_collection_items', 'After:fix_threads', 'After:add_comment_parents']

