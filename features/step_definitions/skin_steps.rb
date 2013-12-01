DEFAULT_CSS = "\"#title { text-decoration: blink;}\""

Given /^basic skins$/ do
  assert Skin.default
  assert WorkSkin.basic_formatting
end

Given /^I set up the skin "([^"]*)"$/ do |skin_name|
  visit new_skin_url
  fill_in("Title", :with => skin_name)
  fill_in("Description", :with => "Random description")
  fill_in("CSS", :with => "#title { text-decoration: blink;}")
end

Given /^I set up the skin "([^"]*)" with css$/ do |skin_name, css|
  step "I set up the skin \"#{skin_name}\""
  fill_in("CSS", :with => css)
end

Given /^I set up the skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  step "I set up the skin \"#{skin_name}\""
  fill_in("CSS", :with => css)
end

Given /^I create the skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  step "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  step %{I submit}
end

Given /^I create the skin "([^"]*)" with css$/ do |skin_name, css|
  step "I set up the skin \"#{skin_name}\" with css \"#{css}\""
  step %{I submit}
end

Given /^I create the skin "([^"]*)"$/ do |skin_name|
  step "I create the skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^I edit the skin "([^"]*)"$/ do |skin_name|
  skin = Skin.find_by_title(skin_name)
  visit edit_skin_path(skin)
end

Given /^the unapproved public skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  step %{I am logged in as "skinner"}
  step %{I set up the skin "#{skin_name}" with css "#{css}"}
  attach_file("skin_icon", "test/fixtures/skin_test_preview.png")
  check("skin_public")
  step %{I submit}
  step %{I should see "Skin was successfully created"}
end

Given /^the unapproved public skin "([^"]*)"$/ do |skin_name|
  step "the unapproved public skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^I approve the skin "([^"]*)"$/ do |skin_name|
  step "I am logged in as an admin"
  visit admin_skins_url
  check("make_official_#{skin_name.gsub(/\s/, '_')}")
  step %{I submit}
end

Given /^I unapprove the skin "([^"]*)"$/ do |skin_name|
  step "I am logged in as an admin"
  visit admin_skins_url
  step "I follow \"Approved Skins\""
  check("make_unofficial_#{skin_name.gsub(/\s/, '_')}")
  step %{I submit}
end

Given /^I have loaded site skins$/ do
  Skin.load_site_css
end

Given /^the approved public skin "([^"]*)" with css "([^"]*)"$/ do |skin_name, css|
  step "the unapproved public skin \"#{skin_name}\" with css \"#{css}\""
  step "I am logged in as an admin"
  step "I approve the skin \"#{skin_name}\""
end

Given /^the approved public skin "([^"]*)"$/ do |skin_name|
  step "the approved public skin \"#{skin_name}\" with css #{DEFAULT_CSS}"
end

Given /^"([^"]*)" is using the approved public skin "([^"]*)" with css "([^"]*)"$/ do |login, skin_name, css|
  step "the approved public skin \"public skin\" with css \"#{css}\""
  step "I am logged in as \"#{login}\""
  step "I am on #{login}'s preferences page"
  select("#{skin_name}", :from => "preference_skin_id")
  step %{I submit}
end

Given /^"([^"]*)" is using the approved public skin "([^"]*)"$/ do |login, skin_name|
  step "\"#{login}\" is using the approved public skin with css #{DEFAULT_CSS}"
end

### WHEN

When /^I change my skin to "([^\"]*)"$/ do |skin_name|
  step "I am on my user page"
    step %{I follow "Preferences"}
    step %{I select "#{skin_name}" from "preference_skin_id"}
    step %{I submit}
  step %{I should see "Your preferences were successfully updated."}
end

When /^I create a skin to change the header color$/ do
  visit new_skin_url
  step %{I follow "Use Wizard Instead?"}
    step %{I fill in "Title" with "Shiny"}
    step %{I fill in "Header color" with "blue"}
    step %{I submit}
  step %{I should see "Skin was successfully created"}
  step %{I press "Use"}
end

When /^I create a skin to change the accent color$/ do
  visit new_skin_url
  step %{I follow "Use Wizard Instead?"}
    step %{I fill in "Title" with "Shiny"}
    step %{I fill in "Accent color" with "blue"}
    step %{I submit}
  step %{I should see "Skin was successfully created"}
  step %{I press "Use"}
end

### THEN

Then /^I should see a different header color$/ do
  step %{I should see "#header, #header ul.main, #footer {background: blue; border-color: blue; box-shadow:none;}" within "style"}
end

Then /^I should see a different accent color on the dashboard and work meta$/ do
  step %{I should see "#header .icon, #dashboard ul, #main dl.meta {background: blue; border-color:blue;}" within "style"}
end
