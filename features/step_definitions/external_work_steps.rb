DEFAULT_EXTERNAL_URL = "http://zooey-glass.dreamwidth.org"
DEFAULT_EXTERNAL_CREATOR = "Zooey Glass"
DEFAULT_EXTERNAL_TITLE = "A Work Not Posted To The AO3"
DEFAULT_EXTERNAL_SUMMARY = "This is my story, I am its author."
DEFAULT_BOOKMARK_NOTES = "I liked this story."
DEFAULT_BOOKMARK_TAGS = "Awesome"

Given /^an external work$/ do
  step %{I set up an external work}
  click_button("Create")
end

Given /^I set up an external work$/ do
  visit new_external_work_path
  fill_in("external_work_url", with: DEFAULT_EXTERNAL_URL)
  fill_in("external_work_author", with: DEFAULT_EXTERNAL_CREATOR)
  fill_in("external_work_title", with: DEFAULT_EXTERNAL_TITLE)
  step %{I fill in basic external work tags}
  fill_in("bookmark_notes", with: DEFAULT_BOOKMARK_NOTES)
  fill_in("bookmark_tag_string", with: DEFAULT_BOOKMARK_TAGS)
end

Given /^I bookmark the external work "([^\"]*)"(?: with fandom "([^"]*)")?(?: with character "([^"]*)")?$/ do |title, fandom, character|
  step %{I set up an external work}
  fill_in("external_work_title", with: title)
  fill_in("external_work_fandom_string", with: fandom) if fandom.present?
  fill_in("external_work_character_string", with: character) if character.present?
  click_button("Create")
end

When /^I view the external work "([^\"]*)"$/ do |external_work|
  external_work = ExternalWork.find_by_title(external_work)
  visit external_work_url(external_work)
end

When /^the (character|fandom|relationship) "(.*?)" is removed from the external work "(.*?)"$/ do |tag_type, tag, title|
  external_work = ExternalWork.find_by(title: title)
  tags = external_work.tags.where(type: tag_type).pluck(:name) - [tag]
  tag_string = tags.join(", ")
  step %{I am logged in as a "policy_and_abuse" admin}
  visit edit_external_work_path(external_work)
  fill_in("work_#{tag_type}", with: tag_string)
  click_button("Update External work")
  step %{all indexing jobs have been run}
end
