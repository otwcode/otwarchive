Given /^I have a bookmark for "([^\"]*)"$/ do |title|
  Given %{I start a new bookmark for "#{title}"}
    And %{I fill in "Your Tags" with "#{DEFAULT_BOOKMARK_TAGS}"}
    And %{I press "Create"}
end

When /^I start a new bookmark for "([^\"]*)"$/ do |title|
  When %{I open the bookmarkable work "#{title}"}  
  click_link("Bookmark")
end

When /^I start a new bookmark$/ do
  When %{I start a new bookmark for "#{DEFAULT_TITLE}"}
end

When /^I edit the bookmark for "([^\"]*)"$/ do |title|
  When %{I open the bookmarkable work "#{title}"}
  click_link("Edit Bookmark")
end

When /^I open a bookmarkable work$/ do
  When %{I open the bookmarkable work "#{DEFAULT_TITLE}"}
end

When /^I open the bookmarkable work "([^\"]*)"$/ do |title|
  work = Work.find_by_title(title)
  if !work
    When %{I post the work "#{title}"}
    work = Work.find_by_title(title)
  end
  visit work_url(work)
end

When /^I add my bookmark to the collection$/ do
  When %{I follow "Add To Collection"}
    fill_in("collection_names", :with => "Various_Penguins")
    click_button("Add")
end
