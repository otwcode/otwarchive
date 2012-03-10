DEFAULT_CSS = "\"#title { text-decoration: blink;}\""

Given /^basic skins$/ do
  assert Skin.default
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
  And %{I submit}
end

Given /^I create the skin "([^"]*)" with css$/ do |skin_name, css|
  Given "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  And %{I submit}
end

Given /^I create the skin "([^"]*)"$/ do |skin_name|
  Given "I create the skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^I edit the skin "([^"]*)"$/ do |skin_name|
  skin = Skin.find_by_title(skin_name)
  visit edit_skin_path(skin)
end

Given /^the unapproved public skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  Given %{I am logged in as "skinner"}
  Given %{I set up the skin "#{skin_name}" with css "#{css}"}
  attach_file("skin_icon", "test/fixtures/skin_test_preview.png")
  check("skin_public")
  And %{I submit}
  Then %{I should see "Skin was successfully created"}
end

Given /^the unapproved public skin "([^"]*)"$/ do |skin_name|
  Given "the unapproved public skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^I approve the skin "([^"]*)"$/ do |skin_name|
  Given "I am logged in as an admin"
  visit admin_skins_url
  check("make_official_#{skin_name.gsub(/\s/, '_')}")
  And %{I submit}
end

Given /^I unapprove the skin "([^"]*)"$/ do |skin_name|
  Given "I am logged in as an admin"
  visit admin_skins_url
  Given "I follow \"Approved Skins\""
  check("make_unofficial_#{skin_name.gsub(/\s/, '_')}")
  And %{I submit}
end

Given /^I have loaded site skins$/ do
  Skin.load_site_css
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
  And %{I submit}
end

Given /^"([^"]*)" is using the approved public skin "([^"]*)"$/ do |login, skin_name|
  Given "\"#{login}\" is using the approved public skin with css #{DEFAULT_CSS}"
end

### WHEN

When /^I change my skin to "([^\"]*)"$/ do |skin_name|
  When "I am on my user page"
    And %{I follow "Preferences"}
    And %{I select "#{skin_name}" from "preference_skin_id"}
    And %{I submit}
  Then %{I should see "Your preferences were successfully updated."}
end

When /^I create a skin to change the header color$/ do
  visit new_skin_url
  When %{I follow "Use Wizard Instead?"}
    And %{I fill in "Title" with "Shiny"}
    And %{I fill in "Header color" with "blue"}
    And %{I submit}
  Then %{I should see "Skin was successfully created"}
  When %{I press "Use"}
end

When /^I create a skin to change the accent color$/ do
  visit new_skin_url
  When %{I follow "Use Wizard Instead?"}
    And %{I fill in "Title" with "Shiny"}
    And %{I fill in "Accent color" with "blue"}
    And %{I submit}
  Then %{I should see "Skin was successfully created"}
  When %{I press "Use"}
end

### THEN

Then /^I should see a different header color$/ do
  Then %{I should see "#header, #header ul.main, #footer {background: blue; border-color: blue; box-shadow:none;}" within "style"}
end

Then /^I should see a different accent color on the dashboard and work meta$/ do
  Then %{I should see "#header .icon, #dashboard ul, #main dl.meta {background: blue; border-color:blue;}" within "style"}
end
