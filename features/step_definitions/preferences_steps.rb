Given /^I set my preferences to View Full Work mode by default$/ do
  user = User.current_user
  user.preference.view_full_works = true
  user.preference.save
end

When /^I set my preferences to receive copies of my own comments$/ do
  user = User.current_user
  user.preference.comment_copy_to_self_off = false
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

When /^I set my preferences to hide warnings$/ do
  user = User.current_user
  user.preference.hide_warnings = true
  user.preference.save
end
