Then /^I should see Posted today$/ do
  today = Date.today.to_s(:date_for_comment_test)
  Given "I should see \"Posted #{today}\""
end
