Given /^basic skins$/ do
  assert Skin.default
  assert Skin.plain_text
  assert WorkSkin.basic_formatting
end


Given /^I set up the skin "([^"]*)" with css "([^"]*)"$/ do |arg1, arg2|
  visit new_skin_url
  fill_in("Title", :with => arg1)
  fill_in("CSS", :with => arg2)
  fill_in("Description", :with => "Random description")
end

Given /^I set up the skin "([^"]*)"$/ do |arg1|
  Given "I set up the skin \"#{arg1}\" with css \"#title { text-decoration: blink;}\""
end

Given /^I create the skin "([^"]*)" with css "([^"]*)"$/ do |arg1, arg2|
  Given "I set up the skin \"#{arg1}\" with css \"#{arg2}\""
  click_button("Create")
end

Given /^I create the skin "([^"]*)"$/ do |arg1|
  Given "I create the skin \"#{arg1}\" with css \"#title { text-decoration: blink;}\""
end

Given /^the unapproved public skin "([^"]*)" with css "([^"]*)"$/ do |arg1, arg2|
  Given "I am logged in as \"skinner\" with password \"password\""
  Given "I set up the skin \"#{arg1}\" with css \"#{arg2}\""
  Given "I attach the file \"test/fixtures/skin_test_preview.png\" to \"skin_icon\""
  check("skin_public")
  click_button("Create")
end

Given /^the unapproved public skin "([^"]*)"$/ do |arg1|
  Given "the unapproved public skin \"#{arg1}\" with css \"#title { text-decoration: blink;}\""
end

Given /^I approve the skin "([^"]*)"$/ do |arg1|
  Given "I am logged in as an admin"
  visit admin_skins_url
  check("#{arg1}")
  click_button("Update")
end

Given /^the approved public skin "([^"]*)" with css "([^"]*)"$/ do |arg1, arg2|
  Given "the unapproved public skin \"#{arg1}\" with css \"#{arg2}\""
  Given "I am logged in as an admin"
  Given "I approve the skin \"#{arg1}\""
end

Given /^the approved public skin "([^"]*)"$/ do |arg1|
  Given "the unapproved public skin \"#{arg1}\" with css \"#title { text-decoration: blink;}\""
end

Given /^I am using the skin "([^"]*)"$/ do |arg1|
  Given "I am on my preferences page"
  select("public skin", :from => "preference_skin_id")
  click_button("Update")
end

