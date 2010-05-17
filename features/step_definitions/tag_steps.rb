When /^I edit the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  click_link_within("Edit", ".header")
end
