###### ERROR MESSAGES
Then /^I should see a not\-in\-fandom error message for "([^"]+)" in "([^"]+)"$/ do |tag, fandom|
  step %{I should see "are not in the selected fandom(s), #{fandom}: #{tag}"}
end

Then /^I should see a not\-in\-fandom error message$/ do 
  step %{I should see "are not in the selected fandom(s)"}
end


### GIVEN

Given /^I have no challenge assignments$/ do
  Collection.delete_all
end

Given /^I have standard challenge tags set ?up$/ do
  begin 
    unless UserSession.find
      step %{I am logged in as "mod1"}
    end
  rescue
    step %{I am logged in as "mod1"}    
  end  
  step "I have no tags"
    step "basic tags"
    step %{a canonical fandom "Stargate Atlantis"}
    step %{a canonical fandom "Stargate SG-1"}
    step %{a canonical character "John Sheppard"}
    step %{a canonical freeform "Alternate Universe - Historical"}
    step %{a canonical freeform "Alternate Universe - High School"}
    step %{a canonical freeform "Something else weird"}
    step %{a canonical freeform "My extra tag"}
    step %{I set up the tag set "Standard Challenge Tags" with the fandom tags "Stargate Atlantis, Stargate SG-1", the character tag "John Sheppard"}
end

Given /^I have Yuletide challenge tags set ?up$/ do
  step "I have standard challenge tags setup"
    step %{I add the fandom tags "Starsky & Hutch, Tiny fandom, Care Bears, Yuletide Hippos RPF" to the tag set "Standard Challenge Tags"}
    step %{a canonical fandom "Starsky & Hutch"}
    step %{a canonical fandom "Tiny fandom"}
    step %{a canonical fandom "Care Bears"}
    step %{a canonical fandom "Yuletide Hippos RPF"}
end

Given /^I have set up the gift exchange "([^\"]*)"$/ do |challengename|
  step %{I have set up the gift exchange "#{challengename}" with name "#{challengename.gsub(/[^\w]/, '_')}"}
end

Given /^I have set up the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  step %{I am logged in as "mod1"}
    step "I have standard challenge tags setup"
    step %{I set up the collection "#{challengename}" with name "#{name}"}
    step %{I select "Gift Exchange" from "challenge_type"}
  click_button("Submit")
end

Given /^I have created the gift exchange "([^\"]*)"$/ do |challengename|
  step %{I have created the gift exchange "#{challengename}" with name "#{challengename.gsub(/[^\w]/, '_')}"}
end

Given /^I have created the gift exchange "([^\"]*)" with name "([^\"]*)"$/ do |challengename, name|
  step %{I have set up the gift exchange "#{challengename}" with name "#{name}"}
  step "I fill in gift exchange challenge options"
    step "I submit"
  step %{I should see "Challenge was successfully created"}  
end

Given /^I have opened signup for the gift exchange "([^\"]*)"$/ do |challengename|
  step %{I am on "#{challengename}" gift exchange edit page}
  check "Sign-up open?"
  step "I submit"
end  

Given /^I have Battle 12 prompt meme set up$/ do
  step %{I am logged in as "mod1"}
    step "I have standard challenge tags setup"
  step "I set up Battle 12 promptmeme collection"
end

Given /^I have Battle 12 prompt meme fully set up$/ do
  step %{I am logged in as "mod1"}
    step "I have standard challenge tags setup"
  step "I set up Battle 12 promptmeme collection"
  step "I fill in Battle 12 challenge options"
end

Given /^I have no-column prompt meme fully set up$/ do
  step %{I am logged in as "mod1"}
    step "I have standard challenge tags setup"
  step "I set up Battle 12 promptmeme collection"
  step "I fill in no-column challenge options"
end

Given /^I have single-prompt prompt meme fully set up$/ do
  step %{I am logged in as "mod1"}
    step "I have standard challenge tags setup"
  step "I set up Battle 12 promptmeme collection"
  step "I fill in single-prompt challenge options"
end

Given /^everyone has signed up for Battle 12$/ do
  # no anon
  step %{I am logged in as "myname1"}
  step %{I sign up for Battle 12 with combination A}

  # both anon
  step %{I am logged in as "myname2"}
  step %{I sign up for Battle 12 with combination B}

  # one anon
  step %{I am logged in as "myname3"}
  step %{I sign up for Battle 12}

  # no anon
  step %{I am logged in as "myname4"}
  step %{I sign up for Battle 12 with combination C}
end

Given /^an anon has signed up for Battle 12$/ do
  # both anon
  step %{I am logged in as "myname2"}
  step %{I sign up for Battle 12 with combination B}
end

Given /^everyone has signed up for the gift exchange "([^\"]*)"$/ do |challengename|
  step %{I am logged in as "myname1"}
  step %{I sign up for "#{challengename}" with combination A}
  step %{I am logged in as "myname2"}
  step %{I sign up for "#{challengename}" with combination B}
  step %{I am logged in as "myname3"}
  step %{I sign up for "#{challengename}" with combination C}
  step %{I am logged in as "myname4"}
  step %{I sign up for "#{challengename}" with combination D}
end

Given /^I have generated matches for "([^\"]*)"$/ do |challengename|
  step %{I close signups for "#{challengename}"}
  step %{I follow "Matching"}
  step %{I follow "Generate Potential Matches"}
  step %{the system processes jobs}
    step %{I wait 3 seconds}
  step %{I reload the page}
  step %{all emails have been delivered}
end

Given /^I have sent assignments for "([^\"]*)"$/ do |challengename|
  step %{I follow "Send Assignments"}
  step %{the system processes jobs}
    step %{I wait 3 seconds}
  step %{I reload the page}
  step %{I should not see "Assignments are now being sent out"}
end

### WHEN

When /^I set up an?(?: ([^"]*)) promptmeme "([^\"]*)"(?: with name "([^"]*)")?$/ do |type, title, name|
  step %{I am logged in as "mod1"}
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
  step %{I submit}
  step "I should see \"Collection was successfully created\""

  check("prompt_meme_signup_open")
  fill_in("prompt_meme_requests_num_allowed", :with => ArchiveConfig.PROMPT_MEME_PROMPTS_MAX)
  fill_in("prompt_meme_requests_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_required", :with => 1)
  fill_in("prompt_meme_request_restriction_attributes_fandom_num_allowed", :with => 2)
  step %{I submit}
  step "I should see \"Challenge was successfully created\""
end

When /^I set up Battle 12 promptmeme collection$/ do
  step %{I am logged in as "mod1"}
  visit new_collection_path
  fill_in("collection_name", :with => "lotsofprompts")
  fill_in("collection_title", :with => "Battle 12")
  fill_in("Introduction", :with => "Welcome to the meme")
  fill_in("FAQ", :with => "<dl><dt>What is this thing?</dt><dd>It is a comment fic thing</dd></dl>")
  fill_in("Rules", :with => "Be nicer to people")
  check("This collection is unrevealed")
  check("This collection is anonymous")
  select("Prompt Meme", :from => "challenge_type")
  step %{I submit}
  step "I should see \"Collection was successfully created\""
end

When /^I create Battle 12 promptmeme$/ do
  step "I set up Battle 12 promptmeme collection"
  step "I fill in Battle 12 challenge options"
end

When /^I fill in Battle 12 challenge options$/ do
  step "I fill in prompt meme challenge options"
    step %{I fill in "Sign-up Instructions" with "Please request easy things"}
    step %{I fill in "Sign-up opens" with "2010-09-20 12:40AM"}
    step %{I fill in "Sign-up closes" with "2016-09-20 12:40AM"}
    step %{I select "(GMT-05:00) Eastern Time (US & Canada)" from "Time zone"}
    step %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    check("prompt_meme_request_restriction_attributes_title_allowed")
    step %{I submit}
end

When /^I fill in future challenge options$/ do
  step "I fill in prompt meme challenge options"
    step %{I fill in "Sign-up opens" with "2015-09-20 12:40AM"}
    step %{I fill in "Sign-up closes" with "2016-09-20 12:40AM"}
    step %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    step %{I uncheck "Sign-up open?"}
    step %{I submit}
end

When /^I fill in past challenge options$/ do
  step "I fill in prompt meme challenge options"
    step %{I fill in "Sign-up opens" with "2010-09-20 12:40AM"}
    step %{I fill in "Sign-up closes" with "2010-09-20 12:40AM"}
    step %{I fill in "prompt_meme_requests_num_allowed" with "3"}
    step %{I uncheck "Sign-up open?"}
    step %{I submit}
end

When /^I fill in no-column challenge options$/ do
  step %{I fill in "prompt_meme_requests_num_required" with "1"}
    step %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "0"}
    step %{I fill in "prompt_meme_request_restriction_attributes_character_num_allowed" with "0"}
    step %{I fill in "prompt_meme_request_restriction_attributes_relationship_num_allowed" with "0"}
    step %{I check "Sign-up open?"}
    step %{I submit}
end

When /^I fill in single-prompt challenge options$/ do
  step %{I fill in "prompt_meme_requests_num_required" with "1"}
    step %{I check "Sign-up open?"}
    check("prompt_meme_request_restriction_attributes_title_allowed")
    step %{I submit}
end

When /^I fill in multi-prompt challenge options$/ do
  step "I fill in prompt meme challenge options"
    step %{I fill in "prompt_meme_requests_num_allowed" with "4"}
    step %{I submit}
end

When /^I fill in prompt meme challenge options$/ do
  step %{I fill in "General Sign-up Instructions" with "Here are some general tips"}
    fill_in("Tag Sets To Use:", :with => "Standard Challenge Tags")
    step %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"}
    step %{I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"}
    step %{I fill in "prompt_meme_request_restriction_attributes_freeform_num_allowed" with "2"}
    step %{I fill in "prompt_meme_requests_num_required" with "2"}
    step %{I check "Sign-up open?"}
end

When /^I fill in gift exchange challenge options$/ do
  current_date = DateTime.current
  fill_in("Sign-up opens", :with => "#{current_date.months_ago(2)}")
    fill_in("Sign-up closes", :with => "#{current_date.years_since(1)}")
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
  step %{I follow "Challenge Settings"}
end

When /^I change the challenge timezone to Alaska$/ do
  step %{I follow "Challenge Settings"}
    step %{I select "(GMT-09:00) Alaska" from "prompt_meme_time_zone"}
    step %{I submit}
    step %{I should see "Challenge was successfully updated"}
end

When /^I open signups for "([^\"]*)"$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Challenge Settings"}
    step %{I check "Sign-up open?"}
    step %{I submit}
  step %{I should see "Challenge was successfully updated"}
end

When /^I view open challenges$/ do
  step "I go to the collections page"
  step %{I follow "Open Challenges"}
end

### WHEN sign up

When /^I start signing up for Battle 12$/ do
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Sign Up"}
end

When /^I sign up for Battle 12$/ do
  step %{I start signing up for Battle 12}
    step %{I check the 1st checkbox with the value "Stargate SG-1"}
    step %{I check the 2nd checkbox with the value "Stargate SG-1"}
    step %{I check the 2nd checkbox with id matching "anonymous"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    step %{I fill in the 1st field with id matching "title" with "crack"}
    # We have to use explicit button names because there are two forms on this page - the form to expand prompts
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination A$/ do
  step %{I start signing up for Battle 12}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - Historical"}
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination B$/ do
  step %{I start signing up for Battle 12}
    step %{I check the 1st checkbox with the value "Stargate SG-1"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    step %{I check the 1st checkbox with id matching "anonymous"}
    step %{I check the 2nd checkbox with id matching "anonymous"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - High School, Something else weird"}
    step %{I fill in the 1st field with id matching "title" with "High School AU SG1"}
    step %{I fill in the 2nd field with id matching "title" with "random SGA love"}
    click_button "Submit"
  step %{I should see "Sign-up was successfully created"}
end

When /^I sign up for Battle 12 with combination C$/ do
  step %{I start signing up for Battle 12}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    step %{I fill in the 1st field with id matching "title" with "weird SGA history AU"}
    step %{I fill in the 2nd field with id matching "title" with "canon SGA love"}
    click_button "Submit"
  step %{I should see "Sign-up was successfully created"}
    step %{I should see "Stargate Atlantis"}
    step %{I should see "Something else weird"}
end

When /^I sign up for Battle 12 with combination D$/ do
  step %{I start signing up for Battle 12}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    click_button "Submit"
end

When /^I sign up for Battle 12 with combination E$/ do
  step "I go to the collections page"
    step "I follow \"Battle 12\""
    step "I follow \"Sign Up\""
    step %{I fill in "Description:" with "Weird description"}
    step "I press \"Submit\""
end

When /^I sign up for "([^\"]*)" fixed-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with value "Stargate SG-1"}
    step %{I check the 2nd checkbox with value "Stargate SG-1"}
    step %{I check the 2nd checkbox with id matching "anonymous"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" many-fandom prompt meme$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I fill in the 1st field with id matching "fandom_tagnames" with "Stargate Atlantis"}
    step %{I check the 1st checkbox with id matching "anonymous"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination A$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I check the 2nd checkbox with value "Stargate SG-1"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - Historical"}
    step %{I fill in the 2nd field with id matching "freeform_tagnames" with "Alternate Universe - High School"}
    click_button "Submit"

end

When /^I sign up for "([^\"]*)" with combination B$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with value "Stargate SG-1"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Alternate Universe - High School, Something else weird"}
    step %{I fill in the 2nd field with id matching "freeform_tagnames" with "Alternate Universe - High School"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination C$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with the value "Stargate SG-1"}
    step %{I check the 2nd checkbox with the value "Stargate SG-1"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    step %{I fill in the 2nd field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination D$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    step %{I fill in the 2nd field with id matching "freeform_tagnames" with "Something else weird, Alternate Universe - Historical"}
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination SGA$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "Stargate Atlantis"}
    fill_in("challenge_signup_requests_attributes_0_title", :with => "SGA love")
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with combination SG-1$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_fandom_tagnames" with "Stargate SG-1"}
    fill_in("challenge_signup_requests_attributes_0_title", :with => "SG1 love")
    click_button "Submit"
end

When /^I sign up for "([^\"]*)" with missing prompts$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with the value "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "Something else weird"}
    click_button "Submit"
end

When /^I start to sign up for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
    step %{I check the 1st checkbox with value "Stargate SG-1"}
end

When /^I start to sign up for "([^\"]*)" gift exchange$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Sign Up"}
end

### WHEN editing signups

When /^I add prompt (\d+)$/ do |number|
  step %{I add prompt #{number} with "Stargate Atlantis"}
end

When /^I add prompt (\d+) with "([^"]+)"$/ do |number, tag|
  step %{I follow "Add Prompt"}
  step %{I should see "Request #{number}"}
  step %{I check the 1st checkbox with the value "#{tag}"}
    # there is only one form on the individual prompt page
    step %{I submit}
  step %{I should see "Prompt was successfully added"}
end

When /^I add prompts up to (\d+) starting with (\d+)$/ do |final_number_of_prompts, start|
  @index = start.to_i
  final_number_of_prompts = final_number_of_prompts.to_i
  while @index <= final_number_of_prompts
    step "I add prompt #{@index}"
    @index = @index + 1
  end
end

When /^I fill in the missing prompt$/ do
  step %{I check the 2nd checkbox with the value "Stargate Atlantis"}
    click_button "Submit"
end

When /^I edit my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Edit Sign-up"}
end

When /^I add a new prompt to my signup$/ do
  step %{I follow "Add Prompt"}
    step %{I check "Stargate Atlantis"}
    step %{I fill in the 1st field with id matching "freeform_tagnames" with "My extra tag"}
    step %{I press "Submit"}
end

When /^I add a new prompt to my signup for a prompt meme$/ do
  step %{I follow "Add Prompt"}
    step %{I check "Stargate Atlantis"}
    step %{I press "Submit"}
end

When /^I edit the signup by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Prompts ("}
  step %{I follow "Edit Sign-up"}
end

### WHEN viewing after signups

When /^I view my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "My Prompts"}
end

When /^I view unposted claims for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  # step %{show me the sidebar}
  step %{I follow "Unposted Claims ("}
end

When /^I view prompts for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Prompts ("}
end

### WHEN claiming

When /^I claim a prompt from "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
    step %{I follow "Prompts ("}
    step %{I press "Claim"}
end

When /^I claim two prompts from "([^\"]*)"$/ do |title|
  step %{I claim a prompt from "#{title}"}
  step %{I claim a prompt from "#{title}"}
end

When /^I want to search for exactly one term$/ do
  Capybara.exact = true
end

### WHEN fulfilling claims

When /^I start to fulfill my claim with "([^\"]*)"$/ do |title|
  step %{I am on my user page}
  step %{I follow "Claims ("}
  step %{I follow "Fulfill"}
    step %{I fill in "Work Title" with "#{title}"}
    step %{I select "Not Rated" from "Rating"}
    step %{I check "No Archive Warnings Apply"}
    step %{I fill in "Fandom" with "Stargate Atlantis"}
    step %{I fill in "content" with "This is an exciting story about Atlantis"}
end

When /^I start to fulfill my claim$/ do
  step %{I start to fulfill my claim with "Fulfilled Story"}
end

When /^I fulfill my claim$/ do
  step %{I start to fulfill my claim with "Fulfilled Story"}
  step %{I press "Preview"}
    step %{I press "Post"}
  step %{I should see "Work was successfully posted"}
end

When /^I fulfill my claim again$/ do
  step %{I am on my user page}
  step %{I follow "Claims ("}
  step %{I follow "Fulfilled Claims"}
  step %{I follow "Fulfill"}
  step %{I fill in "Work Title" with "Second Story"}
    step %{I select "Not Rated" from "Rating"}
    step %{I check "No Archive Warnings Apply"}
    step %{I fill in "Fandom" with "Stargate Atlantis"}
    step %{I fill in "content" with "This is an exciting story about Atlantis"}
  step %{I press "Preview"}
    step %{I press "Post"}
  step %{I should see "Work was successfully posted"}
end

When /^mod fulfills claim$/ do
  step %{I am logged in as "mod1"}
  step %{I claim a prompt from "Battle 12"}
  step %{I start to fulfill my claim}
    step %{I fill in "Work Title" with "Fulfilled Story-thing"}
    step %{I fill in "content" with "This is an exciting story about Atlantis, but in a different universe this time"}
  step %{I press "Preview"}
    step %{I press "Post"}
end

### WHEN fulfilling assignments

When /^I start to fulfill my assignment$/ do
  step %{I am on my user page}
  step %{I follow "Assignments ("}
  step %{I follow "Fulfill"}
    step %{I fill in "Work Title" with "Fulfilled Story"}
    step %{I select "Not Rated" from "Rating"}
    step %{I check "No Archive Warnings Apply"}
    step %{I fill in "Fandom" with "Final Fantasy X"}
    step %{I fill in "content" with "This is a really cool story about Final Fantasy X"}
end

When /^I fulfill my assignment$/ do
  step %{I start to fulfill my assignment}
  step %{I press "Preview"}
    step %{I press "Post"}
  step %{I should see "Work was successfully posted"}
end

### WHEN we need the author attribute to be set
When /^I fulfill my assignment and the author is "([^\"]*)"$/ do |new_user|
  step %{I start to fulfill my assignment}
    step %{I select "#{new_user}" from "Author / Pseud(s)"}
  step %{I press "Preview"}
    step %{I press "Post"}
  step %{I should see "Work was successfully posted"}

end

### WHEN other

When /^I close signups for "([^\"]*)"$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Challenge Settings"}
    step %{I uncheck "Sign-up open?"}
    step %{I press "Update"}
  step %{I should see an update confirmation message}
end

When /^I delete my signup for "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "My Prompts"}
  step %{I follow "Delete Sign-up"}
  step %{I should see "Challenge sign-up was deleted."}
end

When /^I delete my prompt in "([^\"]*)"$/ do |title|
  visit collection_path(Collection.find_by_title(title))
  step %{I follow "Prompts ("}
  step %{I press "Delete Prompt"}
end

When /^I start to delete the signup by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Prompts ("}
end

When /^I delete the prompt by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Prompts ("}
  step %{I follow "Delete Prompt"}
end

When /^I edit the first prompt$/ do
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Prompts ("}
  # The 'Edit Sign-up' and 'Edit Prompt' buttons were removed for mods in
  # Prompt Meme challenges
  #step %{I follow "Edit Prompt"}
end

When /^I edit the prompt by "([^\"]*)"$/ do |participant|
  visit collection_path(Collection.find_by_title("Battle 12"))
  step %{I follow "Prompts ("}
  click_link("#{participant}")
  step %{I follow "Edit"}
end

When /^I reveal the "([^\"]*)" challenge$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
    step %{I follow "Collection Settings"}
    step %{I uncheck "This collection is unrevealed"}
    step %{I press "Update"}
end

When /^I reveal the authors of the "([^\"]*)" challenge$/ do |title|
  step %{I am logged in as "mod1"}
  visit collection_path(Collection.find_by_title(title))
    step %{I follow "Collection Settings"}
    step %{I uncheck "This collection is anonymous"}
    step %{I press "Update"}
end

### THEN

Then /^I should see Battle 12 descriptions$/ do
  step %{I should see "Welcome to the meme" within "#intro"}
  step %{I should see "Sign-up: Open"}
  step %{I should see "Sign-up closes:"}
  step %{I should see "#{Time.now.year}" within ".collection .meta"}
  step %{I should see "What is this thing?" within "#faq"}
  step %{I should see "It is a comment fic thing" within "#faq"}
  step %{I should see "Be nicer to people" within "#rules"}
end

Then /^I should see prompt meme options$/ do
  step %{I should not see "Offer Settings"}
    step %{I should see "Request Settings"}
    step %{I should not see "If you plan to use automated matching"}
    step %{I should not see "Allow Any"}
end

Then /^I should see gift exchange options$/ do
  step %{I should see "Offer Settings"}
    step %{I should see "Request Settings"}
    step %{I should see "If you plan to use automated matching"}
    step %{I should see "Allow Any"}
end

Then /^I should be editing the challenge settings$/ do
  step %{I should see "Setting Up the Battle 12 Prompt Meme"}
end

Then /^signup should be open$/ do
  step %{I should see "Profile" within "div#main .collection .navigation"}
  step %{I should see "Sign-up: Open" within ".collection .meta"}
    step %{I should see "Sign-up closes:"}
end

Then /^I should see both timezones$/ do
  step %{I follow "Profile"}
  step %{I should see "EST ("}
  step %{I should see "AKST)"}
end

Then /^I should see just one timezone$/ do
  step %{I follow "Profile"}
  step %{I should see "Sign-up: Open"}
  step %{I should not see "EST" within "#main"}
  step %{I should see "AKST" within "#main"}
end

Then /^I should see a prompt is claimed$/ do
  # note, prompts are in reverse date order by default
  step %{I should see "New claim made."}
    step %{I should see "My Claims in Battle 12"}
    step %{I should see "Fulfill"}
    step %{I should see "Drop Claim"}
    
  # Claims in the user page are just the prompts that have been claimed
  step "I am on my user page"
    step %{I follow "Claims"}
  step %{I should see "Fulfill"}
    step %{I should see "by Anonymous"}
    step %{I should not see "myname" within ".index"}
end

Then /^I should see correct signups for Battle 12$/ do
  step %{I should see "myname4"}
    step %{I should see "myname3"}
    step %{I should not see "myname2"}
    step %{I should see "by Anonymous"}
    step %{I should see "myname1"}
    step %{I should see "Stargate Atlantis"}
    step %{I should see "Stargate SG-1"}
    step %{I should see "Something else weird"}
    step %{I should see "Alternate Universe - Historical"}
    step %{I should not see "Matching"}
end

Then /^claims are hidden$/ do
  step %{I go to "Battle 12" collection's page}
    step %{I follow "Unposted Claims"}
  step %{I should see "Unposted Claims"}
    step %{I should see "Fulfilled Claims"}
    step %{I should see "myname" within ".claims"}
    step %{I should see "Secret!" within ".claims"}
    step %{I should see "Stargate Atlantis"}
end

Then /^claims are shown$/ do
  step %{I go to "Battle 12" collection's page}
    step %{I follow "Unposted Claims"}
  step %{I should see "myname4" within "h5"}
    step %{I should not see "Secret!"}
    step %{I should see "Stargate Atlantis"}
end

Then /^Battle 12 prompt meme should be correctly created$/ do
  step %{I should see "Challenge was successfully created"}
  step "signup should be open"
  step "Battle 12 collection exists"
end

Then /^My Gift Exchange gift exchange should be correctly created$/ do
  step %{I should see "Collection was successfully created"}
  step %{I should see "Setting Up the My Gift Exchange Gift Exchange"}
  step %{I should see "Offer Settings"}
  step %{I should see "Request Settings"}
  step %{I should see "If you plan to use automated matching"} 
  step %{I should see "Allow Any"}
end

Then /^My Gift Exchange gift exchange should be fully created$/ do
  step %{I should see a create confirmation message}
  step "My Gift Exchange collection exists"
end

Then /^my claim should be fulfilled$/ do
  step %{I should see "Work was successfully posted"}
    step %{I should see "Fandom:"}
    step %{I should see "Stargate Atlantis"}
    step %{I should not see "Alternate Universe - Historical"}
    step %{I should see "In response to a prompt by"}
end

Then /^14 should be the last signup in the table$/ do
  step %{I should see the text with tags "14</a></td>
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
  step "I should see the text with tags \"12</a></td> <td class=\"navigation\"> <!-- requires 'challenge_signup' local --> <ul class=\"navigation\" role=\"navigation\"> <!-- The edit and delete links shouldn't show on the index for a prompt meme --> </ul> </td> </tr> </table>\""
end

Then /^I should see the whole signup$/ do
  page.should have_content("Sign-up for")
  page.should have_content("Requests")
  page.should have_content("Request 1")
  page.should have_content("Request 2")
end

Then /^I should just see request 1$/ do
  page.should have_content("Request by myname1")
  page.should have_content("Edit Sign-up")
  page.should have_content("Edit Prompt")
  page.should have_content("Stargate Atlantis")
  page.should have_content("Alternate Universe - Historical")
  page.should have_no_content("Request 2")
end

Then /^I should see single prompt editing$/ do
  page.should have_content("Edit Sign-up")
  page.should have_content("Additional Tags")
  step %{the field labeled "Additional Tags" should contain "Alternate Universe - Historical"}
  page.should have_no_content("Just add one new prompt instead")
end


