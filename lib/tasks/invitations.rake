namespace :invitations do
  desc "Increase user invitations by the archive limit"
  task(:increase => :environment) do
    for user in User.valid do 
      user.update_attribute(:invitation_limit, user.invitation_limit + ArchiveConfig.INVITATION_LIMIT)
    end
    puts "Invitations increased."
  end
  
  desc "Freeze invitations by setting the limit to 0 for all users"
  task(:freeze => :environment) do
    User.update_all('invitation_limit = 0')
    puts "Invitations frozen."
  end
end
