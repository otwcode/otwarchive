###### ERROR MESSAGES
Then /^I should see a not\-in\-fandom error message for "([^"]+)" in "([^"]+)"$/ do |tag, fandom|
  Then %{I should see "are not in the selected fandom(s), #{fandom}: #{tag}"}
end

Then /^I should see a not\-in\-fandom error message$/ do 
  Then %{I should see "are not in the selected fandom(s)"}
end


### GIVEN

Given /^I have no challenge assignments$/ do
  Collection.delete_all
end

Given /^I have standard challenge tags set ?up$/ do
  begin 
    unless UserSession.find
      Given %{I am logged in as "mod1"}
    end
  rescue
    Given %{I am logged in as "mod1"}    
  end  
  Given "I have no tags"
    And "basic tags"
    And %{a canonical fandom "Stargate Atlantis"}
    And %{a canonical fandom "Stargate SG-1"}
    And %{a canonical character "John Sheppard"}
    And %{a canonical freeform "Alternate Universe - Historical"}
    And %{a canonical freeform "Alternate Universe - High School"}
    And %{a canonical freeform "Something else weird"}
    And %{a canonical freeform "My extra tag"}
    And %{I set up the tag set "Standard Challenge Tags" with the fandom tags "Stargate Atlantis, Stargate SG-1", the character tag "John Sheppard"}
end

Given /^I have Yuletide challenge tags set ?up$/ do
  Given "I have standard challenge tags setup"
    And %{I add the fandom tags "Starsky & Hutch, Tiny fandom, Care Bears, Yuletide Hippos RPF" to the tag set "Standard Challenge Tags"}
    And %{a canonical fandom "Starsky & Hutch"}
    And %{a canonical fandom "Tiny fandom"}
    And %{a canonical fandom "Care Bears"}
    And %{a canonical fandom "Yuletide Hippos RPF"}
end

Given /^I have set up the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I have set up the gift exchange "#{challengename}" with name "#{challengename.gsub(/[^\w]/, '_')}"}
end

Given /^I have set up the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  Given %{I am logged in as "mod1"}
    And "I have standard challenge tags setup"
    And %{I set up the collection "#{challengename}" with name "#{name}"}
    And %{I select "Gift Exchange" from "challenge_type"}
  click_button("Submit")
end

Given /^I have created the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I have created the gift exchange "#{challengename}" with name "#{challengename.gsub(/[^\w]/, '_')}"}
end

Given /^I have created the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  Given %{I have set up the gift exchange "#{challengename}" with name "#{name}"}
  When "I fill in gift exchange challenge options"
    And "I submit"
  Then %{I should see "Challenge was successfully created"}  
end

Given /^I have opened signup for the gift exchange "([^\"]*)"$/ do |challengename|
  Given %{I am on "#{challengename}" gift exchange edit page}
  check "Signup open?"
  And "I submit"
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
end

Given /^I have no-column prompt meme fully set up$/ do
  Given %{I am logged in as "mod1"}
    And "I have standard challenge tags setup"
  When "I set up Battle 12 promptmeme collection"
  When "I fill in no-column challenge options"
end

Given /^I have single-prompt prompt meme fully set up$/ do
  Given %{I am logged in as "mod1"}
    And "I have standard challenge tags setup"
  When "I set up Battle 12 promptmeme collection"
  When "I fill in single-prompt challenge options"
end

Given /^everyone has signed up for Battle 12$/ do
  # no anon
  When %{I am logged in as "myname1"}
  When %{I sign up for Battle 12 with combination A}

  # both anon
  When %{I am logged in as "myname2"}
  When %{I sign up for Battle 12 with combination B}

  # one anon
  When %{I am logged in as "myname3"}
  When %{I sign up for Battle 12}

  # no anon
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
    check("This collection is unrevealed")
    check("This collection is anonymous")
  end
  select("Prompt Meme", :from => "challenge_type")
  And %{I submit}
  Then "I should see \"Collection was successfully created\""

  check("prompt_meme_signup_open")
  fill_in("prompt_meme_requests_num_allowed", :with => ArchiveConfig.PROMPT_MEME_PROMPTS_MAX)
  fill_in("prompt_meme_requests_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_allowed", :with => 2)
  And %{I submit}
  Then "I should see \"Challenge was successfully created\""
end

When /^I set up Battle 12 promptmeme collection$/ do
  Given %{I am logged in as "mod1"}
  visit new_collection_path
  fill_in("collection_name", :with => "lotsofprompts")
  fill_in("collection_title", :with => "Battle 12")
  fill_in("Introduction", :with => "Welcome to the meme")
  fill_in("FAQ", :with => "<dl><dt>What is this thing?</dt><dd>It is a comment fic thing</dd></dl>")
  fill_in("Rules", :with => "Be nicer to people")
  check("This collection is unrevealed")
  check("This collection is anonymous")
  select("Prompt Meme", :from => "challenge_type")
  And %{I submit}
  Then "I should see \"Collection was successfully created\""
end

When /^I create Battle 12 promptmeme$/ do
  When "I set up Battle 12 promptmeme collection"
  When "I fill in Battle 12 challenge options"
end

When /^I fill in Battle 12 challenge options$/ do
  When "I fill in prompt meme challenge options"
    And %{I fill in "Signup Instructions" with "Please request easy things"}
    And %{I fill in "Signup opens" with "2010-09-20 12:40AM"}
    And %{I fill in "Signup closes" with "2016-09-20 12:40AM"}
    And %{I select "(GMT-05:00) Eastern Time (US & Canada)" from "Time zone"}
    And %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    And %{I submit}
end

When /^I fill in future challenge options$/ do
  When "I fill in prompt meme challenge options"
    And %{I fill in "Signup opens" with "2015-09-20 12:40AM"}
    And %{I fill in "Signup closes" with "2016-09-20 12:40AM"}
    And %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    And %{I uncheck "Signup open?"}
    And %{I submit}
end

When /^I fill in past challenge options$/ do
  When "I fill in prompt meme challenge options"
    And %{I fill in "Signup opens" with "2010-09-20 12:40AM"}
    And %{I fill in "Signup closes" with "2010-09-20 12:40AM"}
    And %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    And %{I uncheck "Signup open?"}
    And %{I submit}
end

When /^I fill in unlimited prompt challenge options$/ do
  When "I fill in prompt meme challenge options"
    And %{I check "prompt_meme_request_restriction_attributes_character_restrict_to_fandom"}
    And %{I fill in "prompt_meme_requests_num_allowed" with "50"}
    And %{I submit}
end

When /^I fill in no-column challenge options$/ do
  When %{I fill in "prompt_meme_requests_num_required" with "1"}
    And %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "0"}
    And %{I fill in "prompt_meme_request_restriction_attributes_character_num_allowed" with "0"}
    And %{I fill in "prompt_meme_request_restriction_attributes_relationship_num_allowed" with "0"}
    And %{I check "Signup open?"}
    And %{I submit}
end

When /^I fill in single-prompt challenge options$/ do
  When %{I fill in "prompt_meme_requests_num_required" with "1"}
    And %{I check "Signup open?"}
    And %{I submit}
end

When /^I fill in multi-prompt challenge options$/ do
  When "I fill in prompt meme challenge options"
    And %{I fill in "prompt_meme_requests_num_allowed" with "4"}
    And %{I submit}
end

When /^I fill in prompt meme challenge options$/ do
  When %{I fill in "General Signup Instructions" with "Here are some general tips"}
    fill_in("Tag Sets To Use:", :with => "Standard Challenge Tags")
    And %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"}
    And %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"}
    And %{I fill in "prompt_meme_request_restriction_attributes_freeform_num_allowed" with "2"}
    And %{I fill in "prompt_meme_requests_num_required" with "2"}
    And %{I check "Signup open?"}
end

When /^I fill in gift exchange challenge options$/ do
  When %{I fill in "Signup opens" with "2010-09-20 12:40AM"}
    And %{I fill in "Signup closes" with "2013-09-20 12:40AM"}
    select("(GMT-05:00) Eastern Time (US & Canada)", :from => "gift_exchange_time_zone")
    fill_in("Tag Sets To Use:", :with => "Standard Challenge Tags")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_request_restriction_attributes_freeform_num_allowed", :with => "2")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_required", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_fandom_num_allowed", :with => "1")
    fill_in("gift_exchange_offer_restriction_attributes_freeform_num_allowed", :with => "2")
    select("1", :from => "gift_exchange_potential_match_settings_attributes_num_required_fandoms")
end

When /^I edit settings for "([^\"]*)" challenge$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
end

When /^I change the challenge timezone to Alaska$/ do
  When %{I follow "Challenge Settings"}
    And %{I select "(GMT-09:00) Alaska" from "prompt_meme_time_zone"}
    And %{I submit}
    Then %{I should see "Challenge was successfully updated"}
end

When /^I open signups for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
    And %{I check "Signup open?"}
    And %{I submit}
  Then %{I should see "Challenge was successfully updated"}
end

When /^I view open challenges$/ do
  When "I go to the collections page"
  When %{I follow "See Open Challenges"}
end

### WHEN sign up

When /^I start signing up for Battle 12$/ do
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Sign Up"}
end

When /^I sign up for Battle 12$/ do
  When %{I start signing up for Battle 12}
    And %{I check the 1st checkbox with the value "Stargate SG-1"}
    And %{I check the 2nd checkbox with the value "Stargate SG-1"}
    And %{I check the 2nd checkbox with id matching "anonymous"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    # We have to use explicit button names because there are two forms on this page - the form to expand prompts
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination A$/ do
  When %{I start signing up for Battle 12}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - Historical"}
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination B$/ do
  When %{I start signing up for Battle 12}
    And %{I check the 1st checkbox with the value "Stargate SG-1"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    And %{I check the 1st checkbox with id matching "anonymous"}
    And %{I check the 2nd checkbox with id matching "anonymous"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - High School, Something else weird"}
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination C$/ do
  When %{I start signing up for Battle 12}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    click_button "Submit"
  Then %{I should see "Signup was successfully created"}
    And %{I should see "Stargate Atlantis"}
    And %{I should see "Something else weird"}
end

When /^I sign up for Battle 12 with combination D$/ do
  When %{I start signing up for Battle 12}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination E$/ do
  When "I go to the collections page"
    And "I follow \"Battle 12\""
    And "I follow \"Sign Up\""
    And %{I fill in "Description:" with "Weird description"}
    And "I press \"Submit\""
end

When /^I sign up for "([^\"]*)" fixed-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with value "Stargate SG-1"}
    And %{I check the 2nd checkbox with value "Stargate SG-1"}
    And %{I check the 2nd checkbox with id matching "anonymous"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" many-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I fill in the 1st field with id matching "fandom_tagnames" with "Stargate Atlantis"}
    And %{I check the 1st checkbox with id matching "anonymous"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination A$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I check the 2nd checkbox with value "Stargate SG-1"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - Historical"}
    And %{I fill in the 2nd field with id matching "freeform_tagnames" with "Alternate Universe - High School"}
    click_button "Submit"

end

When /^I sign up for "([^\"]*)" with combination B$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with value "Stargate SG-1"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - High School, Something else weird"}
    And %{I fill in the 2nd field with id matching "freeform_tagnames" with "Alternate Universe - High School"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination C$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with the value "Stargate SG-1"}
    And %{I check the 2nd checkbox with the value "Stargate SG-1"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    And %{I fill in the 2nd field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination D$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    And %{I fill in the 2nd field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination SGA$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "Stargate Atlantis"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination SG-1$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "Stargate SG-1"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with missing prompts$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with the value "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I start to sign up for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
    And %{I check the 1st checkbox with value "Stargate SG-1"}
end

When /^I start to sign up for "([^\"]*)" gift exchange$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Sign Up"}
end

### WHEN editing signups

When /^I add prompt (\d+)$/ do |number|
  When %{I add prompt #{number} with "Stargate Atlantis"}
end

When /^I add prompt (\d+) with "([^"]+)"$/ do |number, tag|
  When %{I follow "Add another prompt"}
  Then %{I should see "Request #{number}"}
  When %{I check the 1st checkbox with the value "#{tag}"}
    # there is only one form on the individual prompt page
    And %{I submit}
  Then %{I should see "Prompt was successfully added"}
end

When /^I add prompts up to (\d+) starting with (\d+)$/ do |final_number_of_prompts, start|
  @index = start.to_i
  final_number_of_prompts = final_number_of_prompts.to_i
  while @index <= final_number_of_prompts
    When "I add prompt #{@index}"
    @index = @index + 1
  end
end

When /^I fill in the missing prompt$/ do
  When %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    click_button "Submit"
end

When /^I edit my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Edit Signup"}
end

When /^I add a new prompt to my signup$/ do
  When %{I follow "Add another prompt"}
    And %{I check "Stargate Atlantis"}
    And %{I fill in the 1st field with id matching "freeform_tagnames" with "My extra tag"}
    And %{I press "Submit"}
end

When /^I add a new prompt to my signup for a prompt meme$/ do
  When %{I follow "Add another prompt"}
    And %{I check "Stargate Atlantis"}
    And %{I press "Submit"}
end

When /^I edit the signup by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Prompts ("}
  When %{I follow "Edit whole signup"}
end

### WHEN viewing after signups

When /^I view my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Your Prompts"}
end

When /^I view unposted claims for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  # And %{show me the main content}
  When %{I follow "Unposted Claims ("}
end

When /^I view prompts for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Prompts ("}
end

### WHEN claiming

When /^I claim a prompt from "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
    And %{I follow "Prompts ("}
    And %{I press "Claim"}
end

When /^I claim two prompts from "([^\"]*)"$/ do |title|
  When %{I claim a prompt from "#{title}"}
  When %{I claim a prompt from "#{title}"}
end

### WHEN fulfilling claims

When /^I start to fulfill my claim with "([^\"]*)"$/ do |title|
  When %{I am on my user page}
  When %{I follow "Claims ("}
  When %{I follow "Fulfill"}
    And %{I fill in "Work Title" with "#{title}"}
    And %{I select "Not Rated" from "Rating"}
    And %{I check "No Archive Warnings Apply"}
    And %{I fill in "Fandom" with "Stargate Atlantis"}
    And %{I fill in "content" with "This is an exciting story about Atlantis"}
end

When /^I start to fulfill my claim$/ do
  When %{I start to fulfill my claim with "Fulfilled Story"}
end

When /^I fulfill my claim$/ do
  When %{I start to fulfill my claim with "Fulfilled Story"}
  When %{I press "Preview"}
    And %{I press "Post"}
  Then %{I should see "Work was successfully posted"}
end

When /^I fulfill my claim again$/ do
  When %{I start to fulfill my claim with "Second Story"}
  When %{I press "Preview"}
    And %{I press "Post"}
  Then %{I should see "Work was successfully posted"}
end

When /^mod fulfills claim$/ do
  When %{I am logged in as "mod1"}
  When %{I claim a prompt from "Battle 12"}
  When %{I start to fulfill my claim}
    And %{I fill in "Work Title" with "Fulfilled Story-thing"}
    And %{I fill in "content" with "This is an exciting story about Atlantis, but in a different universe this time"}
  When %{I press "Preview"}
    And %{I press "Post"}
end

### WHEN fulfilling assignments

When /^I start to fulfill my assignment$/ do
  When %{I am on my user page}
  When %{I follow "Assignments ("}
  When %{I follow "Fulfill"}
    And %{I fill in "Work Title" with "Fulfilled Story"}
    And %{I select "Not Rated" from "Rating"}
    And %{I check "No Archive Warnings Apply"}
    And %{I fill in "Fandom" with "Final Fantasy X"}
    And %{I fill in "content" with "This is a really cool story about Final Fantasy X"}
end

When /^I fulfill my assignment$/ do
  When %{I start to fulfill my assignment}
  When %{I press "Preview"}
    And %{I press "Post"}
  Then %{I should see "Work was successfully posted"}
end

### WHEN other

When /^I close signups for "([^\"]*)"$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Challenge Settings"}
    And %{I uncheck "Signup open?"}
    And %{I press "Update"}
  Then %{I should see an update confirmation message}
end

When /^I delete my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Your Prompts"}
  When %{I follow "Delete"}
  Then %{I should see "Challenge signup was deleted."}
end

When /^I delete my prompt in "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  When %{I follow "Prompts ("}
  When %{I follow "Delete"}
end

When /^I start to delete the signup by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Prompts ("}
end

When /^I delete the prompt by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Prompts ("}
  # Then %{show me the main content}
  When %{I follow "Delete"}
end

When /^I edit the first prompt$/ do
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Prompts ("}
  When %{I follow "Edit prompt"}
end

When /^I edit the prompt by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  When %{I follow "Prompts ("}
  click_link("#{participant}")
  When %{I follow "Edit"}
end

When /^I reveal the "([^\"]*)" challenge$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
    And %{I follow "Settings"}
    And %{I uncheck "This collection is unrevealed"}
    And %{I press "Update"}
end

When /^I reveal the authors of the "([^\"]*)" challenge$/ do |title|
  When %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
    And %{I follow "Settings"}
    And %{I uncheck "This collection is anonymous"}
    And %{I press "Update"}
end

### THEN

Then /^I should see Battle 12 descriptions$/ do
  Then %{I should see "Welcome to the meme" within "#intro"}
  Then %{I should see "Signup: Open"}
  Then %{I should see "Signup closes:"}
  Then %{I should see "2011" within ".collection .meta"}
  Then %{I should see "What is this thing?" within "#faq"}
  Then %{I should see "It is a comment fic thing" within "#faq"}
  Then %{I should see "Be nicer to people" within "#rules"}
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

Then /^I should be editing the challenge settings$/ do
  Then %{I should see "Setting Up The Battle 12 Prompt Meme"}
end

Then /^signup should be open$/ do
  When %{I follow "Profile"}
  Then %{I should see "Signup: Open" within ".collection .meta"}
    And %{I should see "Signup closes:"}
end

Then /^I should see both timezones$/ do
  When %{I follow "Profile"}
  And %{I should see "EST ("}
  And %{I should see "AKST)"}
end

Then /^I should see just one timezone$/ do
  When %{I follow "Profile"}
  Then %{I should see "Signup: Open"}
  And %{I should not see "EST" within "#main"}
  And %{I should see "AKST" within "#main"}
end

Then /^I should see a prompt is claimed$/ do
  # note, prompts are in reverse date order by default
  Then %{I should see "New claim made."}
    And %{I should see "Your Claims In Battle 12"}
    And %{I should see "Fulfill"}
    And %{I should see "Drop Claim"}
    
  # Claims in the user page are just the prompts that have been claimed
  When "I am on my user page"
    And %{I follow "Claims"}
  Then %{I should see "Fulfill"}
    And %{I should see "by Anonymous"}
    And %{I should not see "myname" within ".index"}
end

Then /^I should see correct signups for Battle 12$/ do
  Then %{I should see "myname4"}
    And %{I should see "myname3"}
    And %{I should not see "myname2"}
    And %{I should see "by Anonymous"}
    And %{I should see "myname1"}
    And %{I should see "Stargate Atlantis"}
    And %{I should see "Stargate SG-1"}
    And %{I should see "Something else weird"}
    And %{I should see "Alternate Universe - Historical"}
    And %{I should not see "Matching"}
end

Then /^claims are hidden$/ do
  When %{I go to "Battle 12" collection's page}
    And %{I follow "Unposted Claims"}
  Then %{I should see "Unposted Claims"}
    And %{I should see "Fulfilled Claims"}
    And %{I should see "myname" within ".claims"}
    And %{I should see "Secret!" within ".claims"}
    And %{I should see "Stargate Atlantis"}
end

Then /^claims are shown$/ do
  When %{I go to "Battle 12" collection's page}
    And %{I follow "Unposted Claims"}
  Then %{I should see "myname4" within ".claims"}
    And %{I should not see "Secret!"}
    And %{I should see "Stargate Atlantis"}
end

Then /^Battle 12 prompt meme should be correctly created$/ do
  Then %{I should see "Challenge was successfully created"}
  Then "signup should be open"
  Then "Battle 12 collection exists"
end

Then /^My Gift Exchange gift exchange should be correctly created$/ do
  Then %{I should see "Collection was successfully created"}
  Then %{I should see "Setting Up The My Gift Exchange Gift Exchange"}
  Then %{I should see "Offer Settings"}
  Then %{I should see "Request Settings"}
  Then %{I should see "If you plan to use automated matching"} 
  Then %{I should see "Allow Any"}
end

Then /^My Gift Exchange gift exchange should be fully created$/ do
  Then %{I should see a create confirmation message}
  Then "My Gift Exchange collection exists"
end

Then /^my claim should be fulfilled$/ do
  Then %{I should see "Work was successfully posted"}
    And %{I should see "Fandom:"}
    And %{I should see "Stargate Atlantis"}
    And %{I should not see "Alternate Universe - Historical"}
    And %{I should see "In response to a prompt by:"}
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

Then /^I should see the whole signup$/ do
  page.should have_content("Signup for")
  page.should have_content("Requests")
  page.should have_content("Request 1")
  page.should have_content("Request 2")
end

Then /^I should just see request 1$/ do
  page.should have_content("Request by myname1")
  page.should have_content("Edit whole signup")
  page.should have_content("Edit prompt")
  page.should have_content("Stargate Atlantis")
  page.should have_content("Alternate Universe - Historical")
  page.should have_no_content("Request 2")
end

Then /^I should see single prompt editing$/ do
  page.should have_content("Edit whole signup instead")
  page.should have_content("Freeforms")
  Then %{the field labeled "Freeforms" should contain "Alternate Universe - Historical"}
  page.should have_no_content("Just add one new prompt instead")
end

