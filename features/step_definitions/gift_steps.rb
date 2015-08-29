### NOTE: many of these steps rely on the background in gift.feature

Then /^"(.+)" should be notified by email about their gift "(.+)"$/ do |recipient, title|
  step %{1 email should be delivered to "#{recipient}"}
  step %{the email should contain "A gift work has been posted for you"}
  step %{the email should link to the "#{title}" work page}
end

When /^I have given the work to "(.*?)"/ do |recipient|
  step %{I give the work to "#{recipient}"}
  step %{I post the work without preview}
end

Given(/^I have rejected the work/) do
  step %{I have given the work to "giftee1"}
  step %{I am logged in as "giftee1" with password "something"}
  step %{I view the work "GiftStory1"}
  step %{I follow "Refuse Gift"}
end
