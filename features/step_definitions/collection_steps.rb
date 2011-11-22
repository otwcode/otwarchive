### GIVEN

Given /^mod1 lives in Alaska$/ do
  When %{I am logged in as "mod1" with password "something"}
  
  When %{I go to mod1's preferences page}
  #'
  When %{I select "(GMT-09:00) Alaska" from "preference_time_zone"}
    And %{I press "Update"}
end

Given /^I have (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  When %{I am logged in as "moderator"}
  When %{I create the collection "#{title}" with name "#{name}"}
  When %{I am logged out}
end

Given /^I have (?:a|the) hidden collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  When %{I am logged in as "moderator"}
  When %{I set up the collection "#{title}" with name "#{name}"}
  When %{I check "This collection is unrevealed"}
  And %{I submit}

  When "I am logged out"
end

Given /^I have (?:an|the) anonymous collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  When %{I am logged in as "moderator"}
  When %{I set up the collection "#{title}" with name "#{name}"}
  When %{I check "This collection is anonymous"}
  And %{I submit}

  When "I am logged out"
end

Given /^I have a moderated collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  When %{I am logged in as "moderator"}
  if name
    When %{I set up the collection "#{title}" with name "#{name}"}
  else
    When %{I set up the collection "#{title}"}
  end
  When %{I check "This collection is moderated"}
  And %{I submit}

  When "I am logged out"
end

Given /^I have a closed collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  When %{I am logged in as "moderator"}
  if name
    When %{I set up the collection "#{title}" with name "#{name}"}
  else
    When %{I set up the collection "#{title}"}
  end
  When %{I check "This collection is closed"}
  And %{I submit}

  When "I am logged out"
end

Given /^I have added (?:a|the) co\-moderator "([^\"]*)" to collection "([^\"]*)"$/ do |name, title|
  # create the user 
  Given %{I am logged in as "#{name}"}
  Given %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  click_link("Membership")
  When %{I fill in "participants_to_invite" with "#{name}"}
    And %{I press "Submit"}

  When %{I select "Moderator" from "#{name}_role"}
  click_button("#{name}_submit")
  Then %{I should see "Updated #{name}"}
end

### WHEN

When /^I set up (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  visit new_collection_url
  fill_in("collection_name", :with => name.blank? ? title.gsub(/[^\w]/, '_') : name)
  fill_in("collection_title", :with => title)
end

When /^I create (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  When %{I set up the collection "#{title}" with name "#{name}"}
  And %{I submit}
end

When /^I sort by fandom$/ do
  within(:xpath, "//li[a[contains(@title,'sort')]]") do
    When %{I follow "Fandom"}
  end
end

When /^I reveal works for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Settings"}
  uncheck "This collection is unrevealed"
  click_button "Update"
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

