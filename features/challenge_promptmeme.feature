@collections
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it

  Scenario: Create a prompt meme, sign up for it, basic version

  Given the following activated users exist
    | login          | password    |
    | mod1           | something   |
    | myname1        | something   |
    | myname2        | something   |
    | myname3        | something   |
    | myname4        | something   |
    And I have no tags
    And I have no prompts
    And basic tags
    And I create the fandom "Stargate Atlantis" with id 27
    And I create the fandom "Stargate SG-1" with id 28
    And a freeform exists with name: "Alternate Universe - Historical", canonical: true
    And a freeform exists with name: "Alternate Universe - High School", canonical: true
    And a freeform exists with name: "Something else weird", canonical: true
    And I am logged in as "mod1" with password "something"
  Then I should see "Hi, mod1!"
    And I should see "Log out"
    
  # set up mod's preferences
  
  When I go to mod1's preferences page
  #'
  Then I should see "Your time zone"
    And "TODO: checking an option is selected" is fixed
    # And I should find "(GMT-05:00) Eastern Time (US & Canada)" selected within "preference_time_zone"
  When I select "(GMT-09:00) Alaska" from "preference_time_zone"
    And I press "Update"
  Then I should see "Your preferences were successfully updated."
  
  # set up the challenge
  
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Battle 12"
  When I follow "New Collection"
    And I fill in "Display Title" with "Battle 12"
    And I fill in "Collection Name" with "lotsofprompts"
    And I fill in "Introduction" with "Welcome to the meme"
    And I fill in "FAQ" with "<dl><dt>What is this thing?</dt><dd>It is a comment fic thing</dd></dl>"
    And I fill in "Rules" with "Be nicer to people"
    And I select "Prompt Meme" from "challenge_type"
    And I check "Is this collection currently unrevealed?"
    And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"
    And I should see "Setting Up The Battle 12 Prompt Meme"
    And "TODO: checking an option is selected" is fixed
    # And I should find "(GMT-09:00) Alaska" selected within "prompt_meme_time_zone"
    And I should see "(GMT-09:00) Alaska" within "#main"
  When I fill in "General Signup Instructions" with "Here are some general tips"
    And I fill in "Signup Instructions" with "Please request easy things"
    And I select "2011" from "prompt_meme_signups_open_at_1i"
    And I select "2011" from "prompt_meme_signups_close_at_1i"
    And I select "(GMT-05:00) Eastern Time (US & Canada)" from "prompt_meme_time_zone"
    And I fill in "prompt_meme_request_restriction_attributes_tag_set_attributes_fandom_tagnames" with "Stargate SG-1, Stargate Atlantis"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_required" with "1"
    And I fill in "prompt_meme_request_restriction_attributes_fandom_num_allowed" with "1"
    And I fill in "prompt_meme_request_restriction_attributes_freeform_num_allowed" with "2"
    And I fill in "prompt_meme_requests_num_allowed" with "3"
    And I fill in "prompt_meme_requests_num_required" with "2"
    And I check "Signup open?"
    And I press "Submit"
    And "issue 1859" is fixed
  # Then I should see "If signup is open, signup closed date can't be in the past"
  # When I select "2012" from "prompt_meme_signups_open_at_1i"
  #   And I select "2012" from "prompt_meme_signups_close_at_1i"
  #   And I press "Submit"
  # Then I should see "If signup is open, signup opening date can't be in the future"
  # When I select "2011" from "prompt_meme_signups_open_at_1i"
  #   And I press "Submit"
  Then I should see "Challenge was successfully created"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN" within ".collection.meta"
    And I should see "Signup closes:"
  ### TODO fix timezone dependency before next spring!
    And I should see "EST ("
    And I should see "AKST)"
  When I follow "Challenge Settings"
    And I select "(GMT-09:00) Alaska" from "prompt_meme_time_zone"
    # TODO: Raise an issue to rename this button to something more descriptive
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  When I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN"
  ### TODO fix timezone dependency before next spring!
    And I should not see "EST" within "#main"
    And I should see "AKST" within "#main"
  When I go to the collections page
  Then I should see "Battle 12"
    
  # sign up
  
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
  When I go to the collections page
  Then I should see "Battle 12"
  When I follow "Battle 12"
  Then I should see "Sign Up"
  When I follow "Profile"
  Then I should see "Welcome to the meme" within "#intro"
    And I should see "Signup: CURRENTLY OPEN"
    And I should see "Signup closes:"
    And I should see "2011" within ".collection.meta"
    And I should see "What is this thing?" within "#faq"
    And I should see "It is a comment fic thing" within "#faq"
    And I should see "Be nicer to people" within "#rules"
  When I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - Historical"
    And I check "challenge_signup_requests_attributes_1_fandom_27"
    And I press "Submit"
  Then I should see "Signup was successfully created"
    And I should see "Prompts (2)"
  
  # someone else sign up, with 3 prompts this time once Javascript is working, and with anon prompts
  
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
  Then I should see "Add another prompt? (Up to 3 allowed.)"
    And I should not see "Request 3"
  When I follow "add_section"
    And "Issue 2168" is fixed
  #Then I should see "Request 3"
  #When I check "challenge_signup_requests_attributes_2_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_27"
    And I check "challenge_signup_requests_attributes_0_anonymous"
    And I check "challenge_signup_requests_attributes_1_anonymous"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School, Something else weird"
   # And I fill in "challenge_signup_requests_attributes_2_tag_set_attributes_freeform_tagnames" with "Alternate Universe - High School"
    And I press "Submit"
  Then I should see "Signup was successfully created"
    And I should see "Prompts (4)"
  
  # third person sign up, with an anon prompt
  
  When I follow "Log out"
    And I am logged in as "myname3" with password "something"
  When I sign up for Battle 12
  Then I should see "Signup was successfully created"
  
  # check you can see signups in the dashboard
  
  When I follow "myname3"
  Then I should see "My Signups (1)"
  When I follow "My Signups (1)"
  Then I should see "Battle 12"
  
  # fourth person sign up
  
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I go to the collections page
    And I follow "Battle 12"
  Then I should see "Prompts"
  
  # user claims a prompt
  
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Prompts"
  Then I should see "Editing Options"
    And I should see "Claim"
    And I should see "Stargate Atlantis"
  When I press "prompt_33"
  Then I should see "New claim made."
    And I should see "Claims for Battle 12"
    And I should see "Post To Fulfill"
    And I should see "Delete"
    
  # View the claim

  When I go to myname4's user page
    And I follow "My Claims"
    And I follow "myname1" within "#claims_table"
  Then I should see "Claimed by Anonymous: myname1"
  
  # mod view signups
  
  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
    And I go to "Battle 12" collection's page
    And I follow "Prompts"
  Then I should see "myname4" within "#main"
    And I should see "myname3" within "#main"
    And I should not see "myname2" within "#main"
    And I should see "(Anonymous)" within "#main"
    And I should see "myname1" within "#main"
    And I should see "Something else weird"
    And I should see "Alternate Universe - Historical"
    And I should not see "Matching"
    
  # mod closes signups
  
  When I follow "Challenge Settings"
    And I uncheck "Signup open?"
    And I press "Submit"
  Then I should see "Challenge was successfully updated"
  
  # collection is anonymous-writers but claims are shown for mod
  
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "Unfulfilled Claims"
    And I should see "Fulfilled Claims"
    And I should see "myname4" within "#unfulfilled_claims"
    And I should see "myname1" within "#unfulfilled_claims"
    And I should not see "Secret!" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#main"
    And I should see "Alternate Universe - Historical" within "#main"
    
  # claims are hidden for ordinary user
  
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  Then I should see "Unfulfilled Claims"
    And I should see "Fulfilled Claims"
    And I should not see "myname4" within "#unfulfilled_claims"
    And I should see "myname1" within "#unfulfilled_claims"
    And I should see "Secret!" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#main"
    And I should see "Alternate Universe - Historical" within "#main"
  
  # user posts a fic
  
  When I go to myname4's user page
  Then I should see "My Claims (1)" 
  When I follow "My Claims (1)"
  Then I should see "myname1" within "#claims_table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "Fandom:"
    And I should see "Stargate Atlantis"
    And I should see "Alternate Universe - Historical"
  
  # Claim is completed

  When I go to myname4's user page
  Then I should see "My Claims (0)"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "Secret!" within "#fulfilled_claims"
    And I should not see "Secret!" within "#unfulfilled_claims"
  When I follow "Prompts"
  Then I should see "Also claimed by: (Anonymous)"
  
  # mod claims a prompt

  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  When I press "prompt_34"
  Then I should see "New claim made."
  
  # mod can still see claims even though it's anonymous

    And I should see "Unfulfilled Claims"
    And I should see "mod" within "#unfulfilled_claims"
    And I should see "myname1" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#unfulfilled_claims"
    And I should not see "Alternate Universe - Historical" within "#unfulfilled_claims"
    And I should see "Alternate Universe - Historical" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
  
  # mod posts a fic
  
  When I go to mod1's user page
  Then I should see "My Claims (1)" 
  When I follow "My Claims"
  Then I should see "Your Claims"
    And I should not see "In Battle 12"
    And I should see "Writing For" within "#claims_table"
    And I should see "myname1" within "#claims_table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story-thing"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis, but in the normal universe this time"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
  
  # fic shows what prompt it is fulfilling when mod views it
  
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to prompt by: myname1"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Anonymous" within ".byline"
    And I should see "For myname1"
    And I should not see "mod1" within ".byline"
    And I should not see "Alternate Universe - Historical"
  
  # mod's claim is completed
  
  When I go to mod1's user page
  Then I should see "My Claims (0)"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should not see "mod1" within "#unfulfilled_claims"
  
  # mod can see claims
  
  When I follow "Prompts"
  Then I should see "Also claimed by: myname4"
    And I should see "Also claimed by: mod1"
    And I should not see "Also claimed by: (Anonymous)"

  # users can't see claims

  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  Then I should not see "Also claimed by: myname4"
    And I should not see "Also claimed by: mod1"
    And I should see "Also claimed by: (Anonymous)"
  
  # check that claims can't be viewed

  When I follow "myname1"
  Then I should see "Sorry, you're not allowed to do that."

  # check that completed ficlet is unrevealed

  When I view the work "Fulfilled Story-thing"
  Then I should not see "In response to prompt by: myname1"
    And I should not see "Fandom: Stargate Atlantis"
    And I should not see "Anonymous"
    And I should not see "mod1"
    And I should not see "For myname1"
    And I should not see "Alternate Universe - Historical"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"

  # make challenge revealed but still anon

  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"

  # check ficlet is visible but anon

  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to prompt by: myname1"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Anonymous" within ".byline"
    And I should see "For myname1"
    And I should not see "mod1" within ".byline"
    And I should not see "Alternate Universe - Historical"

  # make challenge un-anon

  When I follow "Log out"
    And I am logged in as "mod1" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Settings"
    And I uncheck "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"

  # user can now see claims

  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  Then I should see "Also claimed by: myname4"
    And I should see "Also claimed by: mod1"
    And I should not see "Also claimed by: (Anonymous)"
    
  # user claims an anon prompt

  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  When I press "prompt_35"
  Then I should see "New claim made."

  # check that anon prompts are still anon on the claims index 
  
    And I should not see "myname2"
    And I should see "Claims (3)"
    
  # check that anon prompts are still anon on the prompts page
  
  When I follow "Prompts"
  Then I should not see "myname2" within "#main"
  
  # TODO: check that anon prompts are still anon on the user claims index and claims show and fulfilling work
  
  # check that claims show as fulfilled
  
  When I follow "Log out"
    And I am logged in as "myname4" with password "something"
    And I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
