### GIVEN

Given /^mod1 lives in Alaska$/ do
  When %{I am logged in as "mod1" with password "something"}
  
  When %{I go to mod1's preferences page}
  #'
  When %{I select "(GMT-09:00) Alaska" from "preference_time_zone"}
    And %{I press "Update"}
  Then %{I should see "Your preferences were successfully updated."}
end

Given /^I have a collection "([^\"]*)"$/ do |title|
  When %{I am logged in as "moderator"}
  When "I create the collection \"#{title}\""
  When "I am logged out"
end

Given /^I have a hidden collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  When %{I am logged in as "moderator"}
  When %{I set up the collection "#{title}" with name "#{name}"}
  When %{I check "Is this collection currently unrevealed?"}
  click_button("Submit")
  Then %{I should see "Collection was successfully created."}
  When "I am logged out"
end

Given /^I have an anonymous collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  When %{I am logged in as "moderator"}
  When %{I set up the collection "#{title}" with name "#{name}"}
  When %{I check "Is this collection currently anonymous?"}
  click_button("Submit")
  Then %{I should see "Collection was successfully created."}
  When "I am logged out"
end

Given /^I have added a co\-moderator "([^\"]*)" to collection "([^\"]*)"$/ do |name, title|
  Given %{I am logged in as "#{name}"}
  Given %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  click_link("Membership")
  When %{I fill in "Add new members" with "#{name}"}
  click_button("Submit")
  When %{I select "Moderator" from "#{name}_role"}
  click_button("#{name}_submit")
  Then %{I should see "Updated #{name}"}
end

### WHEN

When /^I set up the collection "([^\"]*)"$/ do |title|
  visit new_collection_url
  fill_in("collection_name", :with => title.gsub(/[^\w]/, '_'))
  fill_in("collection_title", :with => title)
end

When /^I set up the collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  visit new_collection_url
  fill_in("collection_name", :with => name)
  fill_in("collection_title", :with => title)
end

When /^I create the collection "([^\"]*)"$/ do |title|
  When %{I set up the collection "#{title}"}
  click_button("Submit")
  Then %{I should see "Collection was successfully created."}
end

When /^I sort by fandom$/ do
  When "I follow \"Sort by fandom\""
end

When /^I reveal works for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Settings"}
  uncheck "Is this collection currently unrevealed?"
  click_button "Submit"
end

### THEN

Then /^Battle 12 collection exists$/ do
  When "I go to the collections page"
  Then %{I should see "Collections in the "}
    And %{I should see "Battle 12"}
    And %{I should see "(Open, Unmoderated, Unrevealed, Anonymous, Prompt Meme Challenge)"}
end

Then /^My Gift Exchange collection exists$/ do
  When "I go to the collections page"
  Then %{I should see "Collections in the "}
    And %{I should see "My Gift Exchange"}
    And %{I should see "(Open, Unmoderated, Gift Exchange Challenge)"}
end
