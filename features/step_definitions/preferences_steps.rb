Given /^I set my preferences to View Full Work mode by default$/ do
  user = User.current_user
  user.preference.view_full_works = true
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
  user = User.current_user
  user.preference.hide_warnings = true
  user.preference.save
end

When /^I set my preferences to hide freeform$/ do
  user = User.current_user
  user.preference.hide_freeform = true
  user.preference.save
end

When /^I set my preferences to hide all hit counts$/ do
  user = User.current_user
  user.preference.hide_all_hit_counts = true
  user.preference.save
end

When /^I set my preferences to hide hit counts on my works$/ do
  user = User.current_user
  user.preference.hide_private_hit_count = true
  user.preference.save
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

When /^I set my preferences to turn off viewing history$/ do
  user = User.current_user
  user.preference.history_enabled = false
  user.preference.save
end

When /^I set my time zone to "([^"]*)"$/ do |time_zone|
  user = User.current_user
  user.preference.time_zone = time_zone
  user.preference.save
end

When /^I set my preferences to hide warnings by browser$/ do
  step %{I follow "My Preferences"}
  check("preference[hide_warnings]")
  click_button("Update")
  step %{I should see "Your preferences were successfully updated"}
end

When /^I set my preferences to hide freeform by browser$/ do
  step %{I follow "My Preferences"}
  check("preference[hide_freeform]")
  click_button("Update")
  step %{I should see "Your preferences were successfully updated"}
end


