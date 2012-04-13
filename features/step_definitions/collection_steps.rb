### GIVEN

Given /^mod1 lives in Alaska$/ do
  step %{I am logged in as "mod1" with password "something"}
  step %{I go to mod1's preferences page}
  #'
  select "(GMT-09:00) Alaska", :from => "preference_time_zone"
  click_button "Update"
end

Given /^I have (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I create the collection "#{title}" with name "#{name}"}
  step %{I am logged out}
end

Given /^I have (?:a|the) hidden collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I set up the collection "#{title}" with name "#{name}"}
  check "This collection is unrevealed"
  click_button "Submit"

  step "I am logged out"
end

Given /^I have (?:an|the) anonymous collection "([^\"]*)" with name "([^\"]*)"$/ do |title, name|
  step %{I am logged in as "moderator"}
  step %{I set up the collection "#{title}" with name "#{name}"}
  check "This collection is anonymous"
  click_button "Submit"

  step "I am logged out"
end

Given /^I have a moderated collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  if name
    step %{I set up the collection "#{title}" with name "#{name}"}
  else
    step %{I set up the collection "#{title}"}
  end
  check "This collection is moderated"
  click_button "Submit"

  step "I am logged out"
end

Given /^I have a closed collection "([^\"]*)"(?: with name "([^\"]*)")?$/ do |title, name|
  step %{I am logged in as "moderator"}
  if name
    step %{I set up the collection "#{title}" with name "#{name}"}
  else
    step %{I set up the collection "#{title}"}
  end
  check "This collection is closed"
  click_button "Submit"

  step "I am logged out"
end

Given /^I have added (?:a|the) co\-moderator "([^\"]*)" to collection "([^\"]*)"$/ do |name, title|
  # create the user 
  step %{I am logged in as "#{name}"}
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  click_link("Membership")
  fill_in "participants_to_invite", :with => name
  click_button "Submit"

  select "Moderator", :from => "#{name}_role"
  # TODO: fix the form, it is malformed right now
  click_button("#{name}_submit")
  page.should have_content("Updated #{name}")
end

### WHEN

When /^I set up (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  visit new_collection_url
  fill_in("collection_name", :with => name.blank? ? title.gsub(/[^\w]/, '_') : name)
  fill_in("collection_title", :with => title)
end

When /^I create (?:a|the) collection "([^"]*)"(?: with name "([^"]*)")?$/ do |title, name|
  step %{I set up the collection "#{title}" with name "#{name}"}
  click_button "Submit"
end

When /^I sort by fandom$/ do
  within(:xpath, "//li[a[contains(@title,'sort')]]") do
    follow "Fandom"
  end
end

When /^I reveal works for "([^\"]*)"$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  follow "Settings"
  uncheck "This collection is unrevealed"
  click_button "Update"
end

### THEN

Then /^Battle 12 collection exists$/ do
  visit collections_path
  page.should have_content("Collections in the ")
  page.should have_content("Battle 12")
  page.should have_content("(Open, Unmoderated, Unrevealed, Anonymous, Prompt Meme Challenge)")
end

Then /^My Gift Exchange collection exists$/ do
  visit collections_path
  page.should have_content("Collections in the ")
  page.should have_content("My Gift Exchange")
  page.should have_content("(Open, Unmoderated, Gift Exchange Challenge)")
end

