DEFAULT_EXTERNAL_URL = "http://zooey-glass.dreamwidth.org"
DEFAULT_EXTERNAL_AUTHOR = "Zooey Glass"
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
  fill_in("URL", :with => DEFAULT_EXTERNAL_URL)
  fill_in("Author", :with => DEFAULT_EXTERNAL_AUTHOR)
  fill_in("Title", :with => DEFAULT_EXTERNAL_TITLE)
  step %{I fill in basic external work tags}
  fill_in("Notes", :with => DEFAULT_BOOKMARK_NOTES)
  fill_in("Your Tags", :with => DEFAULT_BOOKMARK_TAGS)
end
