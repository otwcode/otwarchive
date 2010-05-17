Given /^I have no tags$/ do
  Tag.delete_all
  silence_warnings {load "#{RAILS_ROOT}/app/models/fandom.rb"}
end

When /^I edit the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  click_link_within("Edit", ".header")
end
