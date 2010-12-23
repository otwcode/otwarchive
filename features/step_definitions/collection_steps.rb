When /^I create the collection "([^\"]*)"$/ do |title|
  visit new_collection_url
  fill_in("collection_name", :with => "testcollection")
  fill_in("collection_title", :with => title)
  click_button("Submit")
  Then "I should see \"Collection was successfully created.\""
end

Given /^I have no challenge assignments$/ do
  Collection.delete_all
end
