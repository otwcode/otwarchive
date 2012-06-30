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
  Then %{the email should contain "Hello from the Archive of Our Own!"}
  Then %{the email should contain "A fanfic archive including your works has been backed up to the AO3 by #{name}"}
  Then %{the email should contain "your works will not be publicly readable"}
  Then %{the email should contain "Claim or remove your works"}
  Then %{the email should contain "#{work}"}
  Then %{the email should contain "#{fandom}"}
end

Then /^the email should contain claim information$/ do
  Then %{the email should contain "We believe the following stories, which have been uploaded to the Archive by one or more archivists"}
  Then %{the email should contain "either because the email matches the one you are using, or because you used an"}
  Then %{the email should contain "invitation sent to the email address of these stories"}
  Then %{the email should contain "We've assigned you as the author"}
end
