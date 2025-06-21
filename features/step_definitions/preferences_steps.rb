Given /^I set my preferences to View Full Work mode by default$/ do
  step %{I follow "My Preferences"}
  check("preference_view_full_works")
  click_button("Update")
end

Given(/^the user "(.*?)" disallows co-creators$/) do |login|
  user = User.where(login: login).first
  user = find_or_create_new_user(login, DEFAULT_PASSWORD) if user.nil?
  user.preference.allow_cocreator = false
  user.preference.save
end

Given(/^the user "(.*?)" allows co-creators$/) do |login|
  user = User.where(login: login).first
  user = find_or_create_new_user(login, DEFAULT_PASSWORD) if user.nil?
  user.preference.allow_cocreator = true
  user.preference.save
end

Given "the user {string} disallows gifts" do |login|
  user = User.where(login: login).first
  user = find_or_create_new_user(login, DEFAULT_PASSWORD) if user.nil?
  user.preference.allow_gifts = false
  user.preference.save
end

Given "the user {string} allows gifts" do |login|
  user = User.where(login: login).first
  user = find_or_create_new_user(login, DEFAULT_PASSWORD) if user.nil?
  user.preference.allow_gifts = true
  user.preference.save
end

When "the user {string} turns off guest comment replies" do |login|
  user = User.where(login: login).first
  user = find_or_create_new_user(login, DEFAULT_PASSWORD) if user.nil?
  user.preference.update!(guest_replies_off: true)
end

Given "the user {string} is hidden from search engines" do |login|
  user = User.find_by(login: login)
  user.preference.update!(minimize_search_engines: true)
end

When /^I set my preferences to turn off notification emails for comments$/ do
  step %{I follow "My Preferences"}
  check("preference_comment_emails_off")
  click_button("Update")
end

When /^I set my preferences to turn off notification emails for kudos$/ do
  step %{I follow "My Preferences"}
  check("preference_kudos_emails_off")
  click_button("Update")
end

When /^I set my preferences to turn off notification emails for gifts$/ do
  step %{I follow "My Preferences"}
  check("preference_recipient_emails_off")
  click_button("Update")
end

When /^I set my preferences to hide warnings$/ do
  step %{I follow "My Preferences"}
  check("preference_hide_warnings")
  click_button("Update")
end

When /^I set my preferences to hide freeform$/ do
  step %{I follow "My Preferences"}
  check("preference_hide_freeform")
  click_button("Update")
end

When /^I set my preferences to hide the share buttons on my work$/ do
  step %{I follow "My Preferences"}
  check("preference_disable_share_links")
  click_button("Update")
end

When /^I set my preferences to turn off messages to my inbox about comments$/ do
  step %{I follow "My Preferences"}
  check("preference_comment_inbox_off")
  click_button("Update")
end

When /^I set my preferences to turn on messages to my inbox about comments$/ do
  step %{I follow "My Preferences"}
  uncheck("preference_comment_inbox_off")
  click_button("Update")
end

When /^I set my preferences to turn off copies of my own comments$/ do
  step %{I follow "My Preferences"}
  check("preference_comment_copy_to_self_off")
  click_button("Update")
end

When /^I set my preferences to turn on copies of my own comments$/ do
  step %{I follow "My Preferences"}
  uncheck("preference_comment_copy_to_self_off")
  click_button("Update")
end

When /^I set my preferences to turn off the banner showing on every page$/ do
  step %{I follow "My Preferences"}
  check("preference_banner_seen")
  click_button("Update")
end

When /^I set my preferences to turn off history$/ do
  step %{I follow "My Preferences"}
  uncheck("preference_history_enabled")
  click_button("Update")
end

When "the user {string} sets the time zone to {string}" do |username, time_zone|
  user = User.find_by(login: username)
  user.preference.time_zone = time_zone
  user.preference.save
end

When "I set my preferences to allow collection invitations" do
  step %{I follow "My Preferences"}
  check("preference_allow_collection_invitation")
  click_button("Update")
end

When /^I set my preferences to hide both warnings and freeforms$/ do
  step %{I follow "My Preferences"}
  check("preference_hide_warnings")
  check("preference_hide_freeform")
  click_button("Update")
end

When /^I set my preferences to show adult content without warning$/ do
  step %{I follow "My Preferences"}
  check("preference_adult")
  click_button("Update")
end

When /^I set my preferences to warn before showing adult content$/ do
  step %{I follow "My Preferences"}
  uncheck("preference_adult")
  click_button("Update")
end
