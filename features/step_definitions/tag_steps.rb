Given /^I have no tags$/ do
  Tag.delete_all
  silence_warnings {load "#{RAILS_ROOT}/app/models/fandom.rb"}
end

Given /^basic tags$/ do
  Warning.find_or_create_by_name_and_canonical("No Archive Warnings Apply", true)
  Rating.find_or_create_by_name_and_canonical("Not Rated", true)
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
  char = Character.find_or_create_by_name(character)
  fand = Fandom.find_or_create_by_name(fandom)
  char.add_association(fand)
end

