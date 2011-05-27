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
    And %{I am logged in as "mod1"}
    And %{I set up the collection "#{challengename}"}
    And %{I select "Gift Exchange" from "challenge_type"}
  click_button("Submit")
end

Given /^I have set up the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  Given "I have standard challenge tags setup"
    And %{I am logged in as "mod1"}
    And %{I set up the collection "#{challengename}" with name "#{name}"}
    And %{I select "Gift Exchange" from "challenge_type"}
  click_button("Submit")
end
    
Given /^I have created the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I have set up the gift exchange "#{challengename}"}
  When "I fill in gift exchange challenge options"
  click_button("Submit")
end

Given /^I have created the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  Given %{I have set up the gift exchange "#{challengename}" with name "#{name}"}
  When "I fill in gift exchange challenge options"
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

Given /^everyone has signed up for Battle 12$/ do
  When %{I am logged in as "myname1"}
  # no anon
  When %{I sign up for Battle 12 with combination A}
  When %{I am logged in as "myname2"}
  # both anon
  When %{I sign up for Battle 12 with combination B}
  When %{I am logged in as "myname3"}
  # one anon
  When %{I sign up for Battle 12}
  When %{I am logged in as "myname4"}
  When %{I sign up for Battle 12 with combination C}
end

Given /^everyone has signed up for the gift exchange "([^\"]*)"$/ do |challengename|
  When %{I am logged in as "myname1"}
  When %{I sign up for "#{challengename}" with combination A}
  When %{I am logged in as "myname2"}
  When %{I sign up for "#{challengename}" with combination B}
  When %{I am logged in as "myname3"}
  When %{I sign up for "#{challengename}" with combination C}
  When %{I am logged in as "myname4"}
  When %{I sign up for "#{challengename}" with combination D}
end

Given /^I have generated matches for "([^\"]*)"$/ do |challengename|
  When %{I close signups for "#{challengename}"}
  When %{I follow "Matching"}
  When %{I follow "Generate Potential Matches"}
  Given %{the system processes jobs}
    And %{I wait 3 seconds}
  When %{I reload the page}
  When %{all emails have been delivered}
end

Given /^I have sent assignments for "([^\"]*)"$/ do |challengename|
  When %{I follow "Send Assignments"}
  Given %{the system processes jobs}
    And %{I wait 3 seconds}
  When %{I reload the page}
  Then %{I should not see "Assignments are now being sent out"}
end

### WHEN

When /^I view open challenges$/ do
  When "I go to the collections page"
  When %{I follow "See Open Challenges"}
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

When /^I set up an?(?: ([^"]*)) promptmeme "([^\"]*)"(?: with name "([^"]*)")?$/ do |type, title, name|
  When %{I am logged in as "mod1"}
  visit new_collection_path
  if name.nil?
    fill_in("collection_name", :with => "promptcollection")
  else
    fill_in("collection_name", :with => name)
  end
  fill_in("collection_title", :with => title)
  if type == "anon"
    check("Is this collection currently unrevealed?")
    check("Is this collection currently anonymous?")
  end
  select("Prompt Meme", :from => "challenge_type")
  click_button("Submit")
  Then "I should see \"Collection was successfully created\""
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
    And %{I select "2010" from "prompt_meme_signups_open_at_1i"}
    And %{I select "2016" from "prompt_meme_signups_close_at_1i"}
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

When /^I fill in gift exchange challenge options$/ do
    select("2010", :from => "gift_exchange_signups_open_at_1i")
    select("2013", :from => "gift_exchange_signups_close_at_1i")
    select("(GMT-05:00) Eastern Time (US & Canada)", :from => "gift_exchange_time_zone")
    fill_in("gift_exchange_offer_restriction_attributes_tag_set_attributes_fandom_tagnames", :with => "Stargate SG-1, Stargate Atlantis")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_freeform_num_allowed", :with => "2")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_freeform_num_allowed", :with => "2")
    select("1", :from => "gift_exchange_potential_match_settings_attributes_num_required_fandoms")
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

When /^I open signups for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
    And %{I check "Signup open?"}
    And %{I press "Submit"}
  Then %{I should see "Challenge was successfully updated"}
end

When /^I close signups for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
    And %{I uncheck "Signup open?"}
    And %{I press "Submit"}
  Then %{I should see "Challenge was successfully updated"}
end

When /^I sign up for "([^\"]*)" fixed-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When "I follow \"Sign Up\""
    And "I check \"challenge_signup_requests_attributes_0_fandom_28\""
    And "I check \"challenge_signup_requests_attributes_1_fandom_28\""
    And "I check \"challenge_signup_requests_attributes_1_anonymous\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames\" with \"Something else weird\""
    And "I press \"Submit\""
end

When /^I sign up for "([^\"]*)" many-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When "I follow \"Sign Up\""
    And "I fill in \"challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames\" with \"Stargate Atlantis\""
    And "I check \"challenge_signup_requests_attributes_0_anonymous\""
    And "I press \"Submit\""
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

When /^I sign up for "([^\"]*)" with combination D$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_27"}
    And %{I check "challenge_signup_offers_attributes_0_fandom_27"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    And %{I fill in "challenge_signup_offers_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    And %{I press "Submit"}
end

When /^I sign up for "([^\"]*)" with missing prompts$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_27"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird"}
    And %{I press "Submit"}
end

When /^I fill in the missing prompt$/ do
  When %{I check "challenge_signup_requests_attributes_1_fandom_27"}
    And %{I press "Submit"}
end

When /^I start to sign up for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check "challenge_signup_requests_attributes_0_fandom_28"}
end

When /^I view prompts for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Prompts ("}
end

When /^I start to fulfill my claim$/ do
  When %{I am on my user page}
  When %{I follow "My Claims ("}
  When %{I follow "Post To Fulfill"}
    And %{I fill in "Work Title" with "Fulfilled Story"}
    And %{I select "Not Rated" from "Rating"}
    And %{I check "No Archive Warnings Apply"}
    And %{I fill in "content" with "This is an exciting story about Atlantis"}
end

When /^I fulfill my claim$/ do
  When %{I start to fulfill my claim}
  When %{I press "Preview"}
    And %{I press "Post"}
end

When /^I delete my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Your Prompts"}
  When %{I follow "Delete"}
  Then %{I should see "Challenge signup was deleted."}
end

When /^I start to fulfill my assignment$/ do
  When %{I am on my user page}
  When %{I follow "My Assignments ("}
  When %{I follow "Post To Fulfill"}
    And %{I fill in "Work Title" with "Fulfilled Story"}
    And %{I select "Not Rated" from "Rating"}
    And %{I check "No Archive Warnings Apply"}
    And %{I fill in "content" with "This is a really cool story about Final Fantasy X"}
end

When /^I fulfill my assignment$/ do
  When %{I start to fulfill my assignment}
  When %{I press "Preview"}
    And %{I press "Post"}
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
    And %{I should see "Request Settings"}
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

Then /^my claim should be fulfilled$/ do
  Then %{I should see "Work was successfully posted"}
    And %{I should see "Fandom:"}
    And %{I should see "Stargate Atlantis"}
    And %{I should not see "Alternate Universe - Historical"}
end

Then /^14 should be the last signup in the table$/ do
  Then %{I should see the text with tags "14</a></td>
        <td class=\"navigation\">
          <!-- requires 'challenge_signup' local -->
  <ul class=\"navigation\" role=\"navigation\">
    <!-- The edit and delete links shouldn't show on the index for a prompt meme -->
  </ul>

        </td>
      </tr>
  </table>"}
end

Then /^12 should be the last signup in the table$/ do
  Then "I should see the text with tags \"12</a></td> <td class=\"navigation\"> <!-- requires 'challenge_signup' local --> <ul class=\"navigation\" role=\"navigation\"> <!-- The edit and delete links shouldn't show on the index for a prompt meme --> </ul> </td> </tr> </table>\""
end
