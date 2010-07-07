Given /^I have no tags$/ do
  Tag.delete_all
  silence_warnings {load "#{RAILS_ROOT}/app/models/fandom.rb"}
end

When /^I edit the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
  click_link_within("Edit", ".header")
end

When /^I view the tag "([^\"]*)"$/ do |tag|
  tag = Tag.find_by_name!(tag)
  visit tag_url(tag)
end

When /^I create the tag "([^\"]*)" with id (\d+) and type "([^\"]*)"$/ do |name, id, type|
 tag = type.constantize.new(:name => name)
 tag.id = id.to_i
 tag.canonical = true
 tag.save
end

When /^I create the tag "([^\"]*)" with type "([^\"]*)"$/ do |name, type|
 tag = type.constantize.new(:name => name)
 tag.canonical = true
 tag.save
end

Given /^I add the fandom "([^\"]*)" to the character "([^\"]*)"$/ do |fandom, character|
  char = Tag.find_by_name!(character)
  char.add_association(fandom)
end
