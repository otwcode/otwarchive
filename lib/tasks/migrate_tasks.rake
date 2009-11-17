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

  desc "After r1721, clean up orphaned taggings"
  task :clean_up_taggings => 'Tag:clean_up_taggings'
end

# Remove tasks from the list once they've been run on the deployed site
desc "Run all current migrate tasks"
task :After => [:environment, 'After:clean_up_taggings']
