Given /^the page title should include "([^"]*)"$/ do |string|
  expect(page.title).to match /#{string}/
end

