Given /^I set my preferences to View Full Work mode by default$/ do
  user = User.current_user
  user.preference.view_full_works = true
  user.preference.save
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

When /^I set my preferences to turn off notification emails for comments$/ do
  user = User.current_user
  user.preference.comment_emails_off = true
  user.preference.save
end

When /^I set my preferences to turn off notification emails for kudos$/ do
  user = User.current_user
  user.preference.kudos_emails_off = true
  user.preference.save
end

When /^I set my preferences to turn off notification emails for gifts$/ do
  user = User.current_user
  user.preference.recipient_emails_off = true
  user.preference.save
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
  user = User.current_user
  user.preference.disable_share_links = true
  user.preference.save
end

When /^I set my preferences to turn off messages to my inbox about comments$/ do
  user = User.current_user
  user.preference.comment_inbox_off = true
  user.preference.save
end

When /^I set my preferences to turn on messages to my inbox about comments$/ do
  user = User.current_user
  user.preference.comment_inbox_off = false
  user.preference.save
end

When /^I set my preferences to turn off copies of my own comments$/ do
  user = User.current_user
  user.preference.comment_copy_to_self_off = true
  user.preference.save
end

When /^I set my preferences to turn on copies of my own comments$/ do
  user = User.current_user
  user.preference.comment_copy_to_self_off = false
  user.preference.save
end

When /^I set my preferences to turn off the banner showing on every page$/ do
  user = User.current_user
  user.preference.banner_seen = true
  user.preference.save
end

When /^I set my preferences to turn off history$/ do
  user = User.current_user
  user.preference.history_enabled = false
  user.preference.save
end

When /^I set my time zone to "([^"]*)"$/ do |time_zone|
  user = User.current_user
  user.preference.time_zone = time_zone
  user.preference.save
end

When /^I set my preferences to automatically agree to my work being collected$/ do
  user = User.current_user
  user.preference.automatically_approve_collections = true
  user.preference.save
end

When /^I set my preferences to require my approval for my work to be collected$/ do
  user = User.current_user
  user.preference.automatically_approve_collections = false
  user.preference.save
end

When /^I set my preferences to hide both warnings and freeforms$/ do
  step %{I follow "My Preferences"}
  check("preference_hide_warnings")
  check("preference_hide_freeform")
  click_button("Update")
end

When /^I set my preferences to show adult content without warning$/ do
  user = User.current_user
  user.preference.adult = true
  user.preference.save
end

When /^I set my preferences to warn before showing adult content$/ do
  user = User.current_user
  user.preference.adult = false
  user.preference.save
end
