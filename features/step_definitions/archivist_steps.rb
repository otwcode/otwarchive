### GIVEN

Given /^I have an archivist "([^\"]*)"$/ do |name|
  step %{I have pre-archivist setup for "#{name}"}
  step %{I am logged in as an admin}
  step %{I make "#{name}" an archivist}
  step %{I log out}
end

Given /^I have pre-archivist setup for "([^\"]*)"$/ do |name|
  step %{I am logged in as "#{name}"}
  step %{I have loaded the "roles" fixture}
end

### WHEN

When /^I make "([^\"]*)" an archivist$/ do |name|
  fill_in "query", :with => "#{name}"
  click_button "Find"
  check "user_roles_4"
  click_button "Update"
end

When /^I import the work "([^\"]*)"$/ do |url|
  visit new_work_path(:import => true)
  check "Import for others ONLY with permission"
  fill_in "urls", :with => "#{url}"
  check "Post without previewing"
  click_button "Import"
end

### THEN

Then /^I should not see multi-story import messages$/ do
  page.should_not have_content("Importing completed successfully for the following works! (But please check the results over carefully!)")
  page.should_not have_content("Imported Works")
  page.should_not have_content("We were able to successfully upload the following works.")
end

Then /^I should see multi-story import messages$/ do
  page.should have_content("Importing completed successfully for the following works! (But please check the results over carefully!)")
  page.should have_content("Imported Works")
  page.should have_content("We were able to successfully upload the following works.")
end

Then /^I should see import confirmation$/ do
  page.should have_content("We have notified the author(s) you imported stories for. If any were missed, you can also add co-authors manually.")
end

Then /^the email should contain invitation warnings from "([^\"]*)" for work "([^\"]*)" in fandom "([^\"]*)"$/ do |name, work, fandom|
  Then %{the email should contain "Hello from the Archive of Our Own!"}
  Then %{the email should contain "A fanfic archive including your works has been backed up to the AO3 by #{name}"}
  Then %{the email should contain "your works will not appear in Google searches"}
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
