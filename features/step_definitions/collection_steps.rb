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

When /^I sign up for Battle 12$/ do
  When "I go to the collections page"
    And "I follow \"Battle 12\""
    And "I follow \"Sign Up\""
    And "I check \"challenge_signup_requests_attributes_0_fandom_28\""
    And "I check \"challenge_signup_requests_attributes_1_fandom_28\""
    And "I check \"challenge_signup_requests_attributes_1_anonymous\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames\" with \"Something else weird\""
    And "I press \"Submit\""
end
