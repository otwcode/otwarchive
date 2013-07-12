### GIVEN

Given /^I have turned off the banner$/ do
  step "I turn off the banner"
end

### WHEN

When /^an admin sets a custom banner notice$/ do
  step %{I am logged in as an admin}
  step %{I go to the admin-settings page}
  step %{I fill in "Banner notice" with "Custom notice words"}
    step %{I press "Update"}
    # Changing from null to empty string counts as a change to the banner
  step %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^an admin sets a custom banner notice with a link$/ do
  step %{I am logged in as an admin}
  step %{I go to the admin-settings page}
  step %{I fill in "Banner notice" with "Please donate to the <a href=support>OTWtest</a>"}
    step %{I press "Update"}
  step %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^an admin sets a different banner notice$/ do
  step %{I am logged in as an admin}
  step %{I go to the admin-settings page}
  step %{I fill in "Banner notice" with "Other words"}
    step %{I press "Update"}
  step %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^I turn off the banner$/ do
  step %{I am logged in as "newname"}
  step %{I am on my user page}
  step %{I press "Hide this banner"}
end

### THEN

Then /^the banner notice for a logged-in user should be set to "([^\"]*)"$/ do |words|
  step %{I am logged in as "newname"}
  step %{I am on the works page}
  step %{I should see "#{words}"}
end

Then /^the banner notice for a logged-out user should be set to "([^\"]*)"$/ do |words|
  step %{I am logged out}
  step %{I am on the works page}
  step %{I should see "#{words}"}
end

Then /^I should see the first login banner$/ do
  step %{I should see "It looks like you've just logged into the archive for the first time"}
end

Then /^I should not see the first login banner$/ do
  step %{I should not see "It looks like you've just logged into the archive for the first time"}
end

Then /^I should see the first login popup$/ do
  step %{I should see "Here are some tips to help you get started."}
    step %{I should see "To log in, locate and fill in the log in link"}
end
