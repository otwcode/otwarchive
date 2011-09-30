DEFAULT_CSS = "\"#title { text-decoration: blink;}\""

Given /^basic skins$/ do
  assert Skin.default
  assert Skin.plain_text
  assert WorkSkin.basic_formatting
end

Given /^I set up the skin "([^"]*)"$/ do |skin_name|
  visit new_skin_url
  fill_in("Title", :with => skin_name)
  fill_in("Description", :with => "Random description")
  fill_in("CSS", :with => DEFAULT_CSS)
end

Given /^I set up the skin "([^"]*)" with css$/ do |skin_name, css|
  Given "I set up the skin \"#{skin_name}\""
  fill_in("CSS", :with => css)
end

Given /^I set up the skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  Given "I set up the skin \"#{skin_name}\""
  fill_in("CSS", :with => css)
end

Given /^I create the skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  Given "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  click_button("Create")
end

Given /^I create the skin "([^"]*)" with css$/ do |skin_name, css|
  Given "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  click_button("Create")
end

Given /^I create the skin "([^"]*)"$/ do |skin_name|
  Given "I create the skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^the unapproved public skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  Given "I am logged in as \"skinner\""
  Given "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  Given "I attach the file \"test/fixtures/skin_test_preview.png\" to \"skin_icon\""
  check("skin_public")
  click_button("Create")
end

Given /^the unapproved public skin "([^"]*)"$/ do |skin_name|
  Given "the unapproved public skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^I approve the skin "([^"]*)"$/ do |skin_name|
  Given "I am logged in as an admin"
  visit admin_skins_url
  check("#{skin_name}")
  click_button("Update")
end

Given /^I unapprove the skin "([^"]*)"$/ do |skin_name|
  Given "I am logged in as an admin"
  visit admin_skins_url
  Given "I follow \"Approved Skins\""
  check("make_unofficial_#{skin_name.gsub(/\s/, '_')}")
  click_button("Update")
end

Given /^the approved public skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  Given "the unapproved public skin \"#{skin_name}\" with css \"#{css}\""
  Given "I am logged in as an admin"
  Given "I approve the skin \"#{skin_name}\""
end

Given /^the approved public skin "([^"]*)"$/ do |skin_name|
  Given "the approved public skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^"([^"]*)" is using the approved public skin "([^"]*)" with css "([^"]*)"$/ do |login, skin_name, css|
  Given "the approved public skin \"public skin\" with css \"#{css}\""
  Given "I am logged in as \"#{login}\""
  Given "I am on #{login}'s preferences page"
  select("#{skin_name}", :from => "preference_skin_id")
  click_button("Update")
end

Given /^"([^"]*)" is using the approved public skin "([^"]*)"$/ do |login, skin_name|
  Given "\"#{login}\" is using the approved public skin with css #{DEFAULT_CSS}"
end

### WHEN

When /^I change my skin to "([^\"]*)"$/ do |skin_name|
  When "I am on my user page"
    And %{I follow "Preferences"}
    And %{I select "#{skin_name}" from "preference_skin_id"}
    And %{I press "Update"}
  Then %{I should see "Your preferences were successfully updated."}
end

When /^I create a skin to change the header color$/ do
  visit new_skin_url
  When %{I follow "Use Wizard Instead?"}
    And %{I fill in "Title" with "Shiny"}
    And %{I fill in "Header color" with "blue"}
    And %{I press "Create"}
  Then %{I should see "Skin was successfully created"}
  When %{I press "Use"}
end

When /^I create a skin to change the accent color$/ do
  visit new_skin_url
  When %{I follow "Use Wizard Instead?"}
    And %{I fill in "Title" with "Shiny"}
    And %{I fill in "Accent color" with "blue"}
    And %{I press "Create"}
  Then %{I should see "Skin was successfully created"}
  When %{I press "Use"}
end

### THEN

Then /^I should see a different header color$/ do
  Then %{I should see "#header {background-image: none; background-color: blue;}" within "style"}
end

Then /^I should see a different accent color on the dashboard and work meta$/ do
  Then %{I should see "#dashboard ul, #main dl.meta {background-color: blue;}" within "style"}
end
