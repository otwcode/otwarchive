Given /^the page title should include "([^"]*)"$/ do |string|
  expect(page.title).to match /#{string}/
end

Then(/^the page title should not include "(.*?)"$/) do |string|
  expect(page.title).not_to match /#{string}/
end
