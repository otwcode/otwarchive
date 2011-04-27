### GIVEN

Given /^I have no challenge assignments$/ do
  Collection.delete_all
end

Given /^I have standard challenge users$/ do
# figure out how to set up users here later - need mod1 and myname1 to 4
  When %{I am logged in as "mod1"}
    And "I am logged out"
  When %{I am logged in as "myname1"}
    And "I am logged out"
  When %{I am logged in as "myname2"}
    And "I am logged out"
  When %{I am logged in as "myname3"}
    And "I am logged out"
  When %{I am logged in as "myname4"}
    And "I am logged out"
end

Given /^I have standard challenge tags setup$/ do
  Given "I have no tags"
    And "basic tags"
    And %{I create the fandom "Stargate Atlantis" with id 27}
    And %{I create the fandom "Stargate SG-1" with id 28}
    And %{a freeform exists with name: "Alternate Universe - Historical", canonical: true}
    And %{a freeform exists with name: "Alternate Universe - High School", canonical: true}
    And %{a freeform exists with name: "Something else weird", canonical: true}
end

Given /^I have set up the gift exchange "([^\"]*)"$/ do |challengename|
  Given "I have standard challenge tags setup"
    And %{I set up the collection "#{challengename}"}
    And %{I select "Gift Exchange" from "challenge_type"}
  click_button("Submit")
end
    
Given /^I have created the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I have set up the gift exchange "#{challengename}"}
    select("2011", :from => "gift_exchange_signups_open_at_1i")
    select("2011", :from => "gift_exchange_signups_close_at_1i")
    select("(GMT-05:00) Eastern Time (US & Canada)", :from => "gift_exchange_time_zone")
    fill_in("gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames", :with => "Stargate SG-1, Stargate Atlantis")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_freeform_num_allowed", :with => "2")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_freeform_num_allowed", :with => "2")
    select("1", :from => "gift_exchange_potential_match_settings_attributes_num_required_fandoms")
    click_button("Submit")
end

Given /^I have opened signup for the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I am on "#{challengename}" gift exchange edit page}
  check "Signup open?"
  click_button "Submit"
end  

Given /^I have Battle 12 prompt meme set up$/ do
  Given %{I am logged in as "mod1"}
    And "I have standard challenge tags setup"
  When "I set up Battle 12 promptmeme collection"
end

Given /^I have Battle 12 prompt meme fully set up$/ do
  Given %{I am logged in as "mod1"}
    And "I have standard challenge tags setup"
  When "I set up Battle 12 promptmeme collection"
  When "I fill in Battle 12 challenge options"
  When %{I follow "Log out"}
end

### WHEN

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

When /^I sign up for Battle 12 with combination A$/ do
  When "I go to the collections page"
    And "I follow \"Battle 12\""
    And "I follow \"Sign Up\""
    And "I check \"challenge_signup_requests_attributes_0_fandom_27\""
    And "I check \"challenge_signup_requests_attributes_1_fandom_27\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames\" with \"Alternate Universe - Historical\""
    And "I press \"Submit\""
end

When /^I sign up for Battle 12 with combination B$/ do
  When "I go to the collections page"
    And "I follow \"Battle 12\""
    And "I follow \"Sign Up\""
    And "I check \"challenge_signup_requests_attributes_0_fandom_28\""
    And "I check \"challenge_signup_requests_attributes_1_fandom_27\""
    And "I check \"challenge_signup_requests_attributes_0_anonymous\""
    And "I check \"challenge_signup_requests_attributes_1_anonymous\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames\" with \"Alternate Universe - High School, Something else weird\""
    And "I press \"Submit\""
end

When /^I sign up for Battle 12 with combination C$/ do
  When "I go to the collections page"
    And "I follow \"Battle 12\""
    And "I follow \"Sign Up\""
    And "I check \"challenge_signup_requests_attributes_0_fandom_27\""
    And "I check \"challenge_signup_requests_attributes_1_fandom_27\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames\" with \"Something else weird, Alternate Universe - Historical\""
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

When /^I set up Battle 12 promptmeme collection$/ do
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

When /^I create Battle 12 promptmeme$/ do
  When "I set up Battle 12 promptmeme collection"
  When "I fill in Battle 12 challenge options"
end

When /^I fill in Battle 12 challenge options$/ do
  When %{I fill in "General Signup Instructions" with "Here are some general tips"}
    And %{I fill in "Signup Instructions" with "Please request easy things"}
    And %{I select "2011" from "prompt_meme_signups_open_at_1i"}
    And %{I select "2011" from "prompt_meme_signups_close_at_1i"}
    And %{I select "(GMT-05:00) Eastern Time (US & Canada)" from "prompt_meme_time_zone"}
    And %{I fill in "prompt_meme_request_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate SG-1, Stargate Atlantis"}
    And %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"}
    And %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"}
    And %{I fill in "prompt_meme_request_restriction_attributes_freeform_num_allowed" with "2"}
    And %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    And %{I fill in "prompt_meme_requests_num_required" with "2"}
    And %{I check "Signup open?"}
    And %{I press "Submit"}
end

When /^I change the challenge timezone to Alaska$/ do
  When %{I follow "Challenge Settings"}
    And %{I select "(GMT-09:00) Alaska" from "prompt_meme_time_zone"}
    And %{I press "Submit"}
    Then %{I should see "Challenge was successfully updated"}
end

When /^I claim a prompt from "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
    And %{I follow "Prompts ("}
  Then %{I should see "Claim" within "th"}
    And %{I should not see "Sign in to claim prompts"}
  When %{I press "Claim"}
end

When /^I close signups for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
    And %{I uncheck "Signup open?"}
    And %{I press "Submit"}
  Then %{I should see "Challenge was successfully updated"}
end

When /^I sign up for "([^\"]*)" with combination A$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_27"}
    And %{I check "challenge_signup_offers_attributes_0_fandom_28"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - Historical"}
    And %{I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"}
    And %{I press "Submit"}
end

When /^I sign up for "([^\"]*)" with combination B$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_28"}
    And %{I check "challenge_signup_offers_attributes_0_fandom_27"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School, Something else weird"}
    And %{I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"}
    And %{I press "Submit"}
end

When /^I sign up for "([^\"]*)" with combination C$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_28"}
    And %{I check "challenge_signup_offers_attributes_0_fandom_28"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird"}
    And %{I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird"}
    And %{I press "Submit"}
end

### THEN

Then /^I should see Battle 12 descriptions$/ do
  Then "I should see \"Welcome to the meme\" within \"#intro\""
  Then "I should see \"Signup: CURRENTLY OPEN\""
  Then "I should see \"Signup closes:\""
  Then "I should see \"2011\" within \".collection.meta\""
  Then "I should see \"What is this thing?\" within \"#faq\""
  Then "I should see \"It is a comment fic thing\" within \"#faq\""
  Then "I should see \"Be nicer to people\" within \"#rules\""
end

Then /^I should see prompt meme options$/ do
  Then %{I should not see "Offer Settings"}
    And %{I should see "Request Settings"}
    And %{I should not see "If you plan to use automated matching"}
    And %{I should not see "Allow Any"}
end

Then /^I should see gift exchange options$/ do
  Then %{I should see "Offer Settings"}
    And %{I should not see "Request Settings"}
    And %{I should see "If you plan to use automated matching"}
    And %{I should see "Allow Any"}
end

Then /^signup should be open$/ do
  When %{I follow "Profile"}
  Then %{I should see "Signup: CURRENTLY OPEN" within ".collection.meta"}
    And %{I should see "Signup closes:"}
end

Then /^I should see both timezones$/ do
  When %{I follow "Profile"}
  And %{I should see "EST ("}
  And %{I should see "AKST)"}
end

Then /^I should see just one timezone$/ do
  When %{I follow "Profile"}
  Then %{I should see "Signup: CURRENTLY OPEN"}
  And %{I should not see "EST" within "#main"}
  And %{I should see "AKST" within "#main"}
end

Then /^I should see a prompt is claimed$/ do
  # note, prompts are in reverse date order by default
  Then %{I should see "New claim made."}
    And %{I should see "Claims for Battle 12"}
    And %{I should see "Post To Fulfill"}
    And %{I should see "Delete"}
    
  # View the claim
  When "I am on my user page"
    And %{I follow "My Claims"}
    Then %{I should see "Post To Fulfill"}
    Then %{I should not see "myname" within "#claims_table"}
    And %{I follow "Anonymous" within "#claims_table"}
  Then %{I should see "Claimed by Anonymous: Anonymous"}
end

Then /^I should see correct signups for Battle 12$/ do
  Then %{I should see "myname4" within "#main"}
    And %{I should see "myname3" within "#main"}
    And %{I should not see "myname2" within "#main"}
    And %{I should see "(Anonymous)" within "#main"}
    And %{I should see "myname1" within "#main"}
    And %{I should see "Something else weird"}
    And %{I should see "Alternate Universe - Historical"}
    And %{I should not see "Matching"}
end

Then /^claims are hidden$/ do
  When %{I go to "Battle 12" collection's page}
    And %{I follow "Claims"}
  Then %{I should see "Unfulfilled Claims"}
    And %{I should see "Fulfilled Claims"}
    And %{I should see "myname" within "#unfulfilled_claims"}
    And %{I should see "Secret!" within "#unfulfilled_claims"}
    And %{I should see "Stargate Atlantis" within "#main"}
end

Then /^claims are shown$/ do
  When %{I go to "Battle 12" collection's page}
    And %{I follow "Claims"}
    And %{I should see "Unfulfilled Claims"}
    And %{I should see "Fulfilled Claims"}
    And %{I should see "myname4" within "#unfulfilled_claims"}
    And %{I should not see "Secret!" within "#unfulfilled_claims"}
    And %{I should see "Stargate Atlantis" within "#main"}
end

Then /^Battle 12 prompt meme should be correctly created$/ do
  Then %{I should see "Challenge was successfully created"}
  Then "signup should be open"
  Then "Battle 12 collection exists"
end
