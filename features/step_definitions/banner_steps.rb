### GIVEN

Given /^I have turned off the banner$/ do
  When "I turn off the banner"
end

### WHEN

When /^an admin sets a custom banner notice$/ do
  Given %{I am logged in as an admin}
  When %{I go to the admin-settings page}
  When %{I fill in "Banner notice" with "Custom notice words"}
    And %{I press "Update"}
    # Changing from null to empty string counts as a change to the banner
  Then %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^an admin sets a custom banner notice with a link$/ do
  Given %{I am logged in as an admin}
  When %{I go to the admin-settings page}
  When %{I fill in "Banner notice" with "Please donate to the <a href=support>OTWtest</a>"}
    And %{I press "Update"}
  Then %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^an admin sets a different banner notice$/ do
  Given %{I am logged in as an admin}
  When %{I go to the admin-settings page}
  When %{I fill in "Banner notice" with "Other words"}
    And %{I press "Update"}
  Then %{I should see "Setting banner back on for all users. This may take some time"}
end

When /^I turn off the banner$/ do
  Given %{I am logged in as "newname"}
  When %{I am on my user page}
  When %{I press "Hide this banner"}
end

### THEN

Then /^the banner notice for a logged-in user should be set to "([^\"]*)"$/ do |words|
  When %{I am logged in as "newname"}
  When %{I am on the works page}
  Then %{I should see "#{words}"}
end

Then /^the banner notice for a logged-out user should be set to "([^\"]*)"$/ do |words|
  When %{I am logged out}
  When %{I am on the works page}
  Then %{I should see "#{words}"}
end

Then /^I should see the first login banner$/ do
  Then %{I should see "It looks like you've just logged into the archive for the first time"}
end

Then /^I should not see the first login banner$/ do
  Then %{I should not see "It looks like you've just logged into the archive for the first time"}
end

Then /^I should see the first login popup$/ do
  Then %{I should see "Here are some tips to help you get started."}
    And %{I should see "To log in, locate and fill in the log in link"}
end
