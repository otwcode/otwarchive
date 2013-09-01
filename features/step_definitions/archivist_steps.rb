### GIVEN

Given /^I have an archivist "([^\"]*)"$/ do |name|
  step(%{I have pre-archivist setup for "#{name}"})
  step(%{I am logged in as an admin})
    step(%{I make "#{name}" an archivist})
    step(%{I log out})
end

Given /^I have pre-archivist setup for "([^\"]*)"$/ do |name|
  step(%{I am logged in as "#{name}"})
    step(%{I have loaded the "roles" fixture})
end

### WHEN

When /^I make "([^\"]*)" an archivist$/ do |name|
  step(%{I fill in "query" with "#{name}"})
    step(%{I press "Find"})
  step(%{I check "user_roles_4"})
    step(%{I press "Update"})
end

When /^I import the work "([^\"]*)"$/ do |url|
  step(%{I go to the import page})
  step(%{I check "Import for others ONLY with permission"})
    step(%{I fill in "urls" with "#{url}"})
    step(%{I check "Post without previewing"})
    step(%{I press "Import"})
end

### THEN

Then /^I should not see multi-story import messages$/ do
  step %{I should not see "Importing completed successfully for the following works! (But please check the results over carefully!)"}
    step %{I should not see "Imported Works"}
    step %{I should not see "We were able to successfully upload the following works."}
end

Then /^I should see multi-story import messages$/ do
  step %{I should see "Importing completed successfully for the following works! (But please check the results over carefully!)"}
   step %{I should see "Imported Works"}
    step %{I should see "We were able to successfully upload the following works."}
end

Then /^I should see import confirmation$/ do
  step %{I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."}
end

Then /^the email should contain invitation warnings from "([^\"]*)" for work "([^\"]*)" in fandom "([^\"]*)"$/ do |name, work, fandom|
  step %{the email should contain "has recently been imported"}
  step %{the email should contain "Open Doors"}
  step %{the email should contain "#{work}"}
  step %{the email should contain "#{fandom}"}
end

Then /^the email should contain claim information$/ do
  step %{the email should contain "automatically added to your AO3 account"}
end
