When /^I start a new bookmark for "([^\"]*)"$/ do |title|
  When %{I open the bookmarkable work "#{title}"}  
  click_link("Bookmark")
end

When /^I start a new bookmark$/ do
  When %{I start a new bookmark for "#{DEFAULT_TITLE}"}
end

When /^I edit the bookmark for "([^\"]*)"$/ do |title|
  When %{I open the bookmarkable work "#{title}"}
  click_link("Edit/Add Bookmark")
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