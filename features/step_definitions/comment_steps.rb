Then /^I should see Posted today$/ do
  today = Date.today.to_s(:date_for_comment_test)
  Given "I should see \"Posted #{today}\""
end

Then /^I should see Posted nowish$/ do
  nowish = Time.zone.now.to_s(:time_for_comment_test)
  Given "I should see \"Posted #{nowish}\""
end

Then /^I should see Last Edited nowish$/ do
  nowish = Time.zone.now.to_s(:time_for_comment_test)
  Given "I should see \"Last Edited #{nowish}\""
end
