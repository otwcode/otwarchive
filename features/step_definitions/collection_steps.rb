### GIVEN

Given /^mod1 lives in Alaska$/ do
  step %{I am logged in as "mod1" with password "something"}
  
  step %{I go to mod1's preferences page}
  #'
  step %{I select "(GMT-09:00) Alaska" from "preference_time_zone"}
    step %{I press "Update"}
end

Given /^I have (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I create the collection "#{title}" with name "#{name}"}
end

Given /^I have (?:a|the) hidden collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I set up the collection "#{title}" with name "#{name}"}
  step %{I check "This collection is unrevealed"}
  step %{I submit}

  step "I am logged out"
end

Given /^I have (?:an|the) anonymous collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I set up the collection "#{title}" with name "#{name}"}
  step %{I check "This collection is anonymous"}
  step %{I submit}

  step "I am logged out"
end

Given /^I have a moderated collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  if name
    step %{I set up the collection "#{title}" with name "#{name}"}
  else
    step %{I set up the collection "#{title}"}
  end
  step %{I check "This collection is moderated"}
  step %{I submit}

  step "I am logged out"
end

Given /^I have a closed collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  if name
    step %{I set up the collection "#{title}" with name "#{name}"}
  else
    step %{I set up the collection "#{title}"}
  end
  step %{I check "This collection is closed"}
  step %{I submit}

  step "I am logged out"
end

Given /^I have added (?:a|the) co\-moderator "([^\"]*)" to collection "([^\"]*)"$/ do |name, title|
  # create the user 
  step %{I am logged in as "#{name}"}
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  click_link("Membership")
  step %{I fill in "participants_to_invite" with "#{name}"}
    step %{I press "Submit"}

  step %{I select "Moderator" from "#{name}_role"}
  # TODO: fix the form, it is malformed right now
  click_button("#{name}_submit")
  step %{I should see "Updated #{name}"}
end

### WHEN

When /^I set up (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  visit new_collection_url
  fill_in("collection_name", :with => name.blank? ? title.gsub(/[^\w]/, '_') : name)
  fill_in("collection_title", :with => title)
end

When /^I create (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  name = title.gsub(/[^\w]/, '_') if name.blank?
  step %{I set up the collection "#{title}" with name "#{name}"}
  step %{I submit}
end

When /^I sort by fandom$/ do
  within(:xpath, "//li[a[contains(@title,'Sort')]]") do
    step %{I follow "Fandom 1"}
  end
end

When /^I reveal works for "([^\"]*)"$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Collection Settings"}
  uncheck "This collection is unrevealed"
  click_button "Update"
end

### THEN

Then /^Battle 12 collection exists$/ do
  step "I go to the collections page"
  step %{I should see "Collections in the "}
    step %{I should see "Battle 12"}
    step %{I should see "(Open, Unmoderated, Unrevealed, Anonymous, Prompt Meme Challenge)"}
end

Then /^My Gift Exchange collection exists$/ do
  step "I go to the collections page"
  step %{I should see "Collections in the "}
    step %{I should see "My Gift Exchange"}
    step %{I should see "(Open, Unmoderated, Gift Exchange Challenge)"}
end

Then /^I should see a collection not found message for "([^\"]+)"$/ do |collection_name|
  step %{I should see /We couldn't find the collection(?:.+and)? #{collection_name}/}
end
