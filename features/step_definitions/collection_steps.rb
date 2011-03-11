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

When /^I add prompt (\d+)$/ do |number|
  When "I follow \"Add another prompt\""
    And "I check \"challenge_signup_requests_attributes_#{number}_fandom_54\""
    And "I press \"Submit\""
end

When /^I set up a basic promptmeme "([^\"]*)"$/ do |title|
  visit new_collection_path
  fill_in("collection_name", :with => "promptcollection")
  fill_in("collection_title", :with => title)
  select("Prompt Meme", :from => "challenge_type")
  click_button("Submit")
  check("prompt_meme_signup_open")
  fill_in("prompt_meme_requests_num_allowed", :with => ArchiveConfig.PROMPT_MEME_PROMPTS_MAX)
  fill_in("prompt_meme_requests_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_allowed", :with => 2)
  click_button("Submit")
  Then "I should see \"Challenge was successfully created\""
end
