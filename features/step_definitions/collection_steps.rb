### GIVEN

Given /^mod1 lives in Alaska$/ do
  When %{I am logged in as "mod1" with password "something"}
  
  When %{I go to mod1's preferences page}
  #'
  When %{I select "(GMT-09:00) Alaska" from "preference_time_zone"}
    And %{I press "Update"}
  Then %{I should see "Your preferences were successfully updated."}
end

### WHEN

When /^I set up the collection "([^\"]*)"$/ do |title|
  visit new_collection_url
  fill_in("collection_name", :with => "testcollection")
  fill_in("collection_title", :with => title)
end


When /^I create the collection "([^\"]*)"$/ do |title|
  When %{I set up the collection "#{title}"}
  click_button("Submit")
  Then "I should see \"Collection was successfully created.\""
end

When /^I sort by fandom$/ do
  When "I follow \"Sort by fandom\""
end

### THEN

Then /^Battle 12 collection exists$/ do
  When "I go to the collections page"
  Then %{I should see "Collections in the "}
    And %{I should see "Battle 12"}
end
