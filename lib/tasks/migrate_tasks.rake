namespace :After do
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

  desc "Change Warning Tag name"
  task(:after_change_warning_tag_name => :environment) do
    @new = Warning.find_by_name('Choose Not To Warn')
    @old = Warning.find_by_name('Choose Not To Warn For Some Content')
    @none = Warning.find_by_name('None Of These Warnings Apply')
    ThinkingSphinx.deltas_enabled=false
    if @old && @new     
      Tagging.update_all(["tagger_id = ?", @new.id], ["tagger_id = ?", @old.id])
      FilterTagging.update_all(["filter_id = ?", @new.id], ["filter_id = ?", @old.id])
      @new.reset_filter_count
      # if the new tag name was turned into a new tag by the initializer, get rid of it
      newest = Warning.find_by_name('Choose Not To Use Archive Warnings')
      newest.destroy if newest
      @new.update_attribute(:name, 'Choose Not To Use Archive Warnings')
    end
    @none.update_attribute(:name, 'No Archive Warnings Apply') if @none
    ThinkingSphinx.deltas_enabled=true
  end

  desc "Follow-up to warning changes"
  task(:warnings_follow_up => :environment) do
    @new = Warning.find_by_name('Choose Not To Use Archive Warnings')
    @old = Warning.find_by_name('Choose Not To Warn For Some Content')
    ThinkingSphinx.deltas_enabled=false
    if @old && @old.works.count == 0 && @old.filtered_works.count == 0
      @old.destroy
    else
      raise "Something isn't right here! Double-check the first warnings rake task."
    end
    if @new
      @new.update_attribute(:taggings_count, @new.taggings.count)
    end
    ThinkingSphinx.deltas_enabled=true
  end
end

# Remove tasks from the list once they've been run on the deployed site
desc "Run all current migrate tasks"
task :After => [:environment, 'After:after_change_warning_tag_name', 'After:warnings_follow_up']