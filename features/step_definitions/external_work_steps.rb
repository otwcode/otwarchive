DEFAULT_EXTERNAL_URL = "http://zooey-glass.dreamwidth.org"
DEFAULT_EXTERNAL_CREATOR = "Zooey Glass"
DEFAULT_EXTERNAL_TITLE = "A Work Not Posted To The AO3"
DEFAULT_EXTERNAL_SUMMARY = "This is my story, I am its author."
DEFAULT_EXTERNAL_FANDOM = "External Fandom"
DEFAULT_EXTERNAL_RELATIONSHIP = "Charater A & Character B"
DEFAULT_EXTERNAL_CATEGORY = "F/M"
DEFAULT_EXTERNAL_CHARACTERS = "Character A, Character B"
DEFAULT_BOOKMARK_NOTES = "I liked this story."
DEFAULT_BOOKMARK_TAGS = "Awesome"

Given /^an external work$/ do
  step %{I set up an external work}
  click_button("Create")
end

Given /^I set up an external work$/ do
  visit new_external_work_path
  fill_in("bookmark_external_url", with: DEFAULT_EXTERNAL_URL)
  fill_in("bookmark_external_author", with: DEFAULT_EXTERNAL_CREATOR)
  fill_in("bookmark_external_title", with: DEFAULT_EXTERNAL_TITLE)
  step %{I fill in basic external work tags}
  fill_in("bookmark_notes", with: DEFAULT_BOOKMARK_NOTES)
  fill_in("bookmark_tag_string", with: DEFAULT_BOOKMARK_TAGS)
end

Given /^I bookmark the external work "([^\"]*)"$/ do |title|
  visit new_external_work_path
  fill_in("bookmark_external_url", with: DEFAULT_EXTERNAL_URL)
  fill_in("bookmark_external_author", with: DEFAULT_EXTERNAL_CREATOR)
  fill_in("bookmark_external_title", with: title)
  step %{I fill in basic external work tags}
  fill_in("bookmark_notes", with: DEFAULT_BOOKMARK_NOTES)
  fill_in("bookmark_tag_string", with: DEFAULT_BOOKMARK_TAGS)
  click_button("Create")
end

Given /^"([^"]*)" has bookmarked an external work$/ do |user|
  step %{mock websites with no content}
  step %{basic tags}
  step %{I am logged in as "#{user}"}
  visit new_external_work_path
  # We use the labels for some fields because the ids change when
  # JavaScript is enabled
  fill_in("URL", with: "http://example.org/200")
  fill_in("bookmark_external_author", with: DEFAULT_EXTERNAL_CREATOR)
  fill_in("bookmark_external_title", with: DEFAULT_EXTERNAL_TITLE)
  fill_in("bookmark_external_summary", with: DEFAULT_EXTERNAL_SUMMARY)
  fill_in("Fandoms", with: DEFAULT_EXTERNAL_FANDOM)
  select(ArchiveConfig.RATING_TEEN_TAG_NAME, from: "bookmark_external_rating_string")
  check(DEFAULT_EXTERNAL_CATEGORY)
  fill_in("Relationships", with: DEFAULT_EXTERNAL_RELATIONSHIP)
  fill_in("Characters", with: DEFAULT_EXTERNAL_CHARACTERS)
  click_button("Create")
end

When /^I view the external work "([^\"]*)"$/ do |external_work|
  external_work = ExternalWork.find_by_title(external_work)
  visit external_work_url(external_work)
end

Then /^the work info for my new bookmark should match the original$/ do
  works = ExternalWork.where(url: "http://example.org/200").order("created_at ASC")
  original_work = works[0]
  new_work = works[1]
  expect(new_work.author).to eq(original_work.author) 
  expect(new_work.title).to eq(original_work.title)
  step %{the summary and tag info for my new bookmark should match the original}
end

Then /^the title and creator info for my new bookmark should vary from the original$/ do
  works = ExternalWork.where(url: "http://example.org/200").order("created_at ASC")
  original_work = works[0]
  new_work = works[1]
  expect(new_work.author).not_to eq(original_work.author) 
  expect(new_work.title).not_to eq(original_work.title)
end

Then /^the summary and tag info for my new bookmark should match the original$/ do
  works = ExternalWork.where(url: "http://example.org/200").order("created_at ASC")
  original_work = works[0]
  new_work = works[1]
  expect(new_work.summary).to eq(original_work.summary)
  # AO3-5168 means we have to test just certain tag types for now
  # expect(new_work.tags).to eq(original_work.tags)
  expect(new_work.fandoms).to eq(original_work.fandoms)
  expect(new_work.relationships).to eq(original_work.relationships)
  expect(new_work.characters).to eq(original_work.characters)
end
