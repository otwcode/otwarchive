### GIVEN

Given /^I have an archivist "([^\"]*)"$/ do |name|
  Given %{I have pre-archivist setup for "#{name}"}
  When %{I am logged in as an admin}
    And %{I make "#{name}" an archivist}
    And %{I log out}
end

Given /^I have pre-archivist setup for "([^\"]*)"$/ do |name|
  Given %{I am logged in as "#{name}"}
    And %{I have loaded the "roles" fixture}
end

### WHEN

When /^I make "([^\"]*)" an archivist$/ do |name|
  When %{I fill in "query" with "#{name}"}
    And %{I press "Find"}
  When %{I check "user_roles_4"}
    And %{I press "Update"}
end

When /^I import the work "([^\"]*)"$/ do |url|
  When %{I go to the import page}
  When %{I check "Import for others ONLY with permission"}
    And %{I fill in "urls" with "#{url}"}
    And %{I check "Post without previewing"}
    And %{I press "Import"}
end

### THEN

Then /^I should not see multi-story import messages$/ do
  Then %{I should not see "Importing completed successfully for the following works! (But please check the results over carefully!)"}
    And %{I should not see "Imported Works"}
    And %{I should not see "We were able to successfully upload the following works."}
end

Then /^I should see multi-story import messages$/ do
  Then %{I should see "Importing completed successfully for the following works! (But please check the results over carefully!)"}
    And %{I should see "Imported Works"}
    And %{I should see "We were able to successfully upload the following works."}
end

Then /^I should see import confirmation$/ do
  Then %{I should see "We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually."}
end

Then /^the email should contain invitation warnings from "([^\"]*)" for work "([^\"]*)" in fandom "([^\"]*)"$/ do |name, work, fandom|
  Then %{the email should contain "has recently been imported by"}
  Then %{the email should contain "Open Doors"}
  Then %{the email should contain "we believe that the following fanworks belong to you"}
  Then %{the email should contain "the archivist #{name} has decided to move"}
  Then %{the email should contain "your works will only be readable by logged-in users"}
  Then %{the email should contain "Claim or remove your works"}
  Then %{the email should contain "#{work}"}
  Then %{the email should contain "#{fandom}"}
end

Then /^the email should contain claim information$/ do
  Then %{the email should contain "automatically added to your AO3 account"}
end
