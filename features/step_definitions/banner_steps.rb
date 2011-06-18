### GIVEN

Given /^I have turned off the banner$/ do
  When "I turn off the banner"
end

### WHEN

When /^I turn off the banner$/ do
  Given %{I am logged in as "newname"}
  When %{I am on my user page}
  When %{I follow "Hide this banner"}
end

### THEN

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
