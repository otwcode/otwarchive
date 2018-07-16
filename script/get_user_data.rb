#!script/rails runner
# usage:
# bundle exec rails c
# load "#{Rails.root}/script/get_user_data.rb"

include Rails.application.routes.url_helpers

# Base URL
default_url_options[:host] = ArchiveConfig.APP_URL

# Prompt for the username
print "Enter username: "
login = gets.chomp.downcase

# Find the user
u = User.find_by(login: login)

# URLs of all comments
comment_urls = []
u.comments&.pluck(:id).map do |id|
  comment_urls << "#{comments_url}/#{id}"
end

# URLs of all works user has kudosed
# Kudos can only be on works now, but there is a pull request for admin posts
kudosed_item_urls = [] 
u.kudos&.pluck(:commentable_type, :commentable_id).map do |type, id|
  kudosed_item_urls << "#{ArchiveConfig.APP_URL}/#{type.underscore.downcase}s/#{id}"
end

# URLs of all nominations made in tag sets
tag_set_nomination_urls = []
TagSetNomination.where(pseud_id: u.pseuds.pluck(:id))&.pluck(:id, :owned_tag_set_id).map do |id, tag_set_id|
  tag_set_nomination_urls << "#{tag_sets_url}/#{tag_set_id}/nominations/#{id}"
end

# Name of user's Fannish Next of Kin
if u.fannish_next_of_kin
  next_of_kin = User.find(u.fannish_next_of_kin.pluck(:user_id)).login
end

# Names of people listing user as their FNOK
next_of_kin_for = []
FannishNextOfKin.where(kin_id: u.id)&.pluck(:user_id).map do |id|
  next_of_kin_for << User.find(id).login
end

# List of roles in collections
collection_roles = []
u.pseuds.each do |pseud|
  pseud.collection_participants&.pluck(:participant_role, :collection_id).map do |role, collection_id|
    collection_roles << "#{role} in #{collections_url}/#{Collection.find(collection_id).name}"
  end
end

# List of IP addresses
# Don't include IPs from the audits table because some IPs may be admins'
ips = []
u.comments.pluck(:ip_address)&.map { |ip| ips << ip if !ip.blank? }
u.works.pluck(:ip_address)&.map { |ip| ips << ip if !ip.blank? }

# List of user agents
user_agents = []
u.comments.pluck(:user_agent)&.map { |ua| user_agents << ua if !ua.blank? }

# List of changes made to the user account
# IP addresses, usernames, and emails are personal data; dates are for clarity
# Actions that are or may be taken by admins are excluded to avoid revealing
# admins' personal data
account_changes = []
audited_changes = u.audits.pluck(:audited_changes, :remote_address, :created_at)
audited_changes.map do |change|
  action_hash = change[0]
  ip = change[1].present? ? "the IP address #{change[1]}" : "an unknown IP address"
  date = change[2]
  action_hash.each do |k, v|
    if k == "accepted_tos_version"
      account_changes << "Accepted TOS from #{ip} on #{date}"
    elsif k == "email"
      account_changes << "Changed email from #{v[0]} to #{v[1]} from #{ip} on #{date}"
    elsif k == "failed_login_count"
      account_changes << "Failed login attempt from #{ip} on #{date}"
    elsif k == "login"
      account_changes << "Changed username from #{v[0]} to #{v[1]} from #{ip} on #{date}"
    elsif k == "recently_reset"
      account_changes << "Request password reset from from #{ip} on #{date}"
    end
  end
end

puts "Data for #{u.login} (#{u.email})"
unless ips.empty?
  puts
  puts "IP Addresses:"
  ips.uniq.map do |ip|
    puts "  #{ip}"
  end
end
unless user_agents.empty?
  puts
  puts "User Agents:"
  user_agents.uniq.map do |user_agent|
   puts "  #{user_agent}"
  end
end
if u.fannish_next_of_kin || !next_of_kin_for.empty?
  puts
  puts "Fannish Next of Kin: #{next_of_kin}" if u.fannish_next_of_kin
  puts "Fannish Next of Kin For: #{next_of_kin_for.to_sentence}" unless next_of_kin_for.empty?
end
puts
puts "Pseuds: #{user_pseuds_url(u)}"
puts "Profile: #{user_profile_url(u)}"
puts "Preferences: #{user_preferences_url(u)}"
puts
puts "Works: #{user_works_url(u)}"
puts "Drafts: #{drafts_user_works_url(u)}"
puts "Series: #{user_series_index_url(u)}"
puts "Bookmarks: #{user_bookmarks_url(u)}"
puts
puts "Collections: #{user_collections_url(u)}"
unless collection_roles.empty?
  puts "Collection Roles: "
  collection_roles.map do |role|
    puts "  #{role}"
  end
end
puts
puts "Tag Sets: #{user_tag_sets_url(u)}"
unless tag_set_nomination_urls.empty?
  puts "Tag Set Nominations: "
  tag_set_nomination_urls.map do |url|
    puts "  #{url}"
  end
end
puts
puts "Challenge Sign-ups: #{user_signups_url(u)}"
puts "Gift Exchange Assignments: #{user_assignments_url(u)}"
puts "Prompt Meme Claims: #{user_claims_url(u)}"
puts
puts "History and Marked for Later: #{user_readings_url(u)}"
puts "Subscriptions: #{user_subscriptions_url(u)}"
puts
puts "Gifts: #{user_gifts_url(u)}"
puts "Related Works: #{user_related_works_url(u)}"
puts
puts "Skins: #{user_skins_url(u)}"
puts
puts "Favorite Tags: #{root_url}"
puts "Invitations: #{user_invitations_url(u)}"
unless comment_urls.empty?
  puts
  puts "Comments Left: "
  comment_urls.map do |url|
    puts "  #{url}"
  end
end
unless kudosed_item_urls.empty?
  puts
  puts "Kudos Given To: "
  kudosed_item_urls.map do |url|
    puts "  #{url}"
  end
end
unless account_changes.empty?
  puts
  puts "Account Changes:"
  account_changes.map do |change|
    puts "  #{change}"
  end
end

