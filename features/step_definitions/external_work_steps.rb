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

When /^I view the external work "([^\"]*)"$/ do |external_work|
  external_work = ExternalWork.find_by_title!(external_work)
  visit external_work_url(external_work)
end