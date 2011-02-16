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

When /^I set up an anon promptmeme "([^\"]*)"$/ do |title|
  visit new_collection_path
  fill_in("collection_name", :with => "promptcollection")
  fill_in("collection_title", :with => title)
  check("Is this collection currently unrevealed?")
  check("Is this collection currently anonymous?")
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

When /^I set up Battle 12 promptmeme$/ do
  visit new_collection_path
  fill_in("collection_name", :with => "lotsofprompts")
  fill_in("collection_title", :with => "Battle 12")
  fill_in("Introduction", :with => "Welcome to the meme")
  fill_in("FAQ", :with => "<dl><dt>What is this thing?</dt><dd>It is a comment fic thing</dd></dl>")
  fill_in("Rules", :with => "Be nicer to people")
  check("Is this collection currently unrevealed?")
  check("Is this collection currently anonymous?")
  select("Prompt Meme", :from => "challenge_type")
  click_button("Submit")
  Then "I should see \"Collection was successfully created\""
end

When /^I sort by fandom$/ do
  When "I follow \"Sort by fandom\""
end

Then /^I should see Battle 12 descriptions$/ do
  Then "I should see \"Welcome to the meme\" within \"#intro\""
  Then "I should see \"Signup: CURRENTLY OPEN\""
  Then "I should see \"Signup closes:\""
  Then "I should see \"2011\" within \".collection.meta\""
  Then "I should see \"What is this thing?\" within \"#faq\""
  Then "I should see \"It is a comment fic thing\" within \"#faq\""
  Then "I should see \"Be nicer to people\" within \"#rules\""
end
###########################################################
def collection
  visit new_collection_url
  fill_in("collection_name", :with => "defaultcollection")
  fill_in("collection_title", :with => "Default Collection")
  click_button("Submit")
end
### Given
Given /^I have (\d+) collection$/ do |count|
  count.to_i.times do |i|
    collection
  end
end
### Then
Then /^my collection is orphaned$/ do
  User.orphan_account.collections.count.should == 1
end

