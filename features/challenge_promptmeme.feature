@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Issue 1859
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
  And "issue 1859" is fixed
  # Then I should see "If signup is open, signup closed date can't be in the past"
  # When I select "2012" from "prompt_meme_signups_open_at_1i"
  #   And I select "2012" from "prompt_meme_signups_close_at_1i"
  #   And I press "Submit"
  # Then I should see "If signup is open, signup opening date can't be in the future"
  # When I select "2011" from "prompt_meme_signups_open_at_1i"
  #   And I press "Submit"
  Then I should see "Challenge was successfully created"
  
  Scenario: Timezone defect
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
    
  # set up mod's preferences
  Given mod1 lives in Alaska
  
  When I set up Battle 12 promptmeme
    And "TODO: checking an option is selected" is fixed
    # And I should find "(GMT-09:00) Alaska" selected within "prompt_meme_time_zone"
    And I should see "(GMT-09:00) Alaska" within "#main"
  Then I should see prompt meme options
  When I fill in some more Battle 12 options
  Then I should see "Challenge was successfully created"
  ### TODO fix timezone dependency before next spring! Or not.
  #  Then I should see the timezone problem
  When I change the challenge timezone to Alaska
  # Then I should see just one timezone

  Scenario: Create a prompt meme

  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  
  # Confirm it's not there already, left over from another test
  Then Battle 12 should not exist
  
  # set up the challenge
  When I set up Battle 12 promptmeme
  Then I should see "Setting Up The Battle 12 Prompt Meme"
  Then I should see prompt meme options
  When I fill in some more Battle 12 options
  Then I should see "Challenge was successfully created"
  Then signup should be open
  When I go to the collections page
  Then I should see "Battle 12"
  
  Scenario: User can see a prompt meme

  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
  When I follow "Log out"
    And I am logged in as "myname1"
  When I go to the collections page
  Then I should see "Battle 12"
  
  Scenario: User can see profile descriptions
  
  Given I have standard challenge tags setup
  # set up the challenge
    And I am logged in as "mod1"
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
  When I follow "Log out"
    And I am logged in as "myname1"
  When I go to "Battle 12" collection's page
  When I follow "Profile"
  Then I should see Battle 12 descriptions
  
  Scenario: Sign up for a prompt meme and miss out some fields

  Given I have standard challenge tags setup
    And I am logged in as "mod1" with password "something"
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
    
  # sign up, with errors if you fail to fill in required fields
  
  When I follow "Log out"
    And I am logged in as "myname1"
  When I go to "Battle 12" collection's page
  Then I should see "Sign Up"
  When I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Alternate Universe - Historical"
    And I press "Submit"
    And "Issue 2249" is fixed
  Then I should see "Request must have exactly 1 fandom tags. You currently have none."
  When I check "challenge_signup_requests_attributes_1_fandom_27"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  
  Scenario: Sign up without Javascript
  
  Given I have standard challenge tags setup
  # set up the challenge
    And I am logged in as "mod1"
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
  
  When I follow "Log out"
    And I am logged in as "myname2"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_28"
  Then I should see "Add another prompt? (Up to 3 allowed.)"
    And I should not see "Request 3"
  When I follow "add_section"
    And "Issue 2168" is fixed
  #Then I should see "Request 3"
  
  Scenario: View signups in the dashboard
  
  Given I have standard challenge tags setup
    And I am logged in as "mod1"
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
  
  When I follow "Log out"
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
    And I should see "Prompts (2)"
    
  When I follow "myname1"
  Then I should see "My Signups (1)"
  When I follow "My Signups (1)"
  Then I should see "Battle 12"
    
  Scenario: All the rest of the unrefactored stuff

  Given I have standard challenge users
    And I have standard challenge tags setup
  # set up the challenge
    And I am logged in as "mod1"
  When I set up Battle 12 promptmeme
  When I fill in some more Battle 12 options
    
  # sign up with no anon prompts
  
  When I follow "Log out"
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
    And I should see "Prompts (2)"
  
  # someone else sign up, with both anon prompts
  
  When I follow "Log out"
    And I am logged in as "myname2" with password "something"
  When I sign up for Battle 12 with combination B
  Then I should see "Signup was successfully created"
    And I should see "Prompts (4)"
  
  # third person sign up, with one anon prompt
  
  When I follow "Log out"
    And I am logged in as "myname3"
  When I sign up for Battle 12
  Then I should see "Signup was successfully created"
  
  # fourth person sign up
  
  When I follow "Log out"
    And I am logged in as "myname4"
  When I go to "Battle 12" collection's page
    And I follow "Sign Up"
    And I check "challenge_signup_requests_attributes_0_fandom_27"
    And I check "challenge_signup_requests_attributes_1_fandom_27"
    And I fill in "challenge_signup_requests_attributes_0_tag_set_attributes_freeform_tagnames" with "Something else weird, Alternate Universe - Historical"
    And I press "Submit"
  Then I should see "Signup was successfully created"
  When I go to the collections page
    And I follow "Battle 12"
  Then I should see "Prompts"
  
  # user views prompts and sorts them
  
  When I follow "Prompts ("
    And I follow "Sort by date"
  Then I should see "Something else weird"
  When I follow "Sort by fandom"
  Then I should see "Something else weird"
  
  # user claims a prompt
  
  When I follow "Log out"
    And I am logged in as "myname4"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Prompts (8)"
  Then I should see "Claim" within "th"
    And I should not see "Sign in to claim prompts"
    And I should see "Stargate Atlantis"
  When I press "Claim"
  # note, prompts are in reverse date order by default, so myname4 will have claimed their own prompt here
  Then I should see "New claim made."
    And I should see "Claims for Battle 12"
    And I should see "Post To Fulfill"
    And I should see "Delete"
    
  # View the claim

  When I am on my user page
    And I follow "My Claims"
    And I follow "myname4" within "#claims_table"
  Then I should see "Claimed by Anonymous: myname4"
  
  # mod view signups
  
  When I follow "Log out"
    And I am logged in as "mod1"
    And I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
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
    And I should not see "Secret!" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#main"
    
  # claims are hidden for ordinary user
  
  When I follow "Log out"
    And I am logged in as "myname4"
    And I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "Unfulfilled Claims"
    And I should see "Fulfilled Claims"
    And I should see "myname4" within "#unfulfilled_claims"
    And I should see "Secret!" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#main"
  
  # user posts a fic
  
  When I am on my user page
  Then I should see "My Claims (1)" 
  When I follow "My Claims (1)"
  Then I should see "myname4" within "#claims_table"
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
    And I should not see "Alternate Universe - Historical"
  
  # Claim is completed

  When I am on my user page
  Then I should see "My Claims (0)"
  When I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "Secret!" within "#fulfilled_claims"
    And I should not see "Secret!" within "#unfulfilled_claims"
  When I follow "Prompts (8)"
    And I follow "Show Claims"
  Then I should not see "Claimed by: (Anonymous)"
  When I follow "Show Filled"
  Then I should see "Claimed by: (Anonymous) (Filled)"
  
  # mod claims a prompt

  When I follow "Log out"
    And I am logged in as "mod1"
  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  When I press "Claim"
  Then I should see "New claim made."
  
  # mod can still see claims even though it's anonymous

    And I should see "Unfulfilled Claims"
    And I should see "mod" within "#unfulfilled_claims"
    And I should see "myname4" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#unfulfilled_claims"
    And I should see "Alternate Universe - Historical" within "#unfulfilled_claims"
    And I should not see "Alternate Universe - Historical" within "#fulfilled_claims"
    And I should see "Stargate Atlantis" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
  
  # mod posts a fic
  
  When I am on my user page
  Then I should see "My Claims (1)" 
  When I follow "My Claims"
  Then I should see "Your Claims"
    And I should not see "In Battle 12"
    And I should see "Writing For" within "#claims_table"
    And I should see "myname4" within "#claims_table"
  When I follow "Post To Fulfill"
    And I fill in "Work Title" with "Fulfilled Story-thing"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "content" with "This is an exciting story about Atlantis, but in a different universe this time"
  When I press "Preview"
    And I press "Post"
  Then I should see "Work was successfully posted"
  
  # fic shows what prompt it is fulfilling when mod views it
  
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to a prompt by: myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Anonymous" within ".byline"
    And I should see "For myname4"
    And I should not see "mod1" within ".byline"
    And I should see "Alternate Universe - Historical"
  
  # mod's claim is completed
  
  When I am on my user page
  Then I should see "My Claims (0)"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should not see "mod1" within "#unfulfilled_claims"
  
  # mod can see claims
  
  When I follow "Prompts"
    And I follow "Show Claims"
  Then I should not see "Claimed by: myname4"
    And I should not see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"
  When I follow "Show Filled"
  Then I should see "Claimed by: myname4"
    And I should see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"

  # users can't see claims

  When I follow "Log out"
    And I am logged in as "myname4"
  When I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
    And I follow "Show Claims"
    And I follow "Show Filled"
  Then I should not see "Claimed by: myname4"
    And I should not see "Claimed by: mod1"
    And I should see "Claimed by: (Anonymous)"
  
  # TODO: check that claims can't be viewed

  # check that completed ficlet is unrevealed

  When I view the work "Fulfilled Story-thing"
  Then I should not see "In response to a prompt by: myname4"
    And I should not see "Fandom: Stargate Atlantis"
    And I should not see "Anonymous"
    And I should not see "mod1"
    And I should not see "For myname4"
    And I should not see "Alternate Universe - Historical"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"

  # make challenge revealed but still anon

  When I follow "Log out"
    And I am logged in as "mod1"
  When I go to "Battle 12" collection's page
    And I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"
  # 2 stories are now revealed, so notify the prompters/recipients
    And 2 emails should be delivered
  

  # check ficlet is visible but anon

  When I follow "Log out"
    And I am logged in as "myname4"
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to a prompt by: myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Collections: Battle 12"
    And I should see "Anonymous" within ".byline"
    And I should see "For myname4"
    And I should not see "mod1" within ".byline"
    And I should see "Alternate Universe - Historical"

  # make challenge un-anon

  When I follow "Log out"
    And I am logged in as "mod1"
  When I go to "Battle 12" collection's page
    And I follow "Settings"
    And I uncheck "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"
  # TODO: Figure out if this is actually right, or if it's covered by the earlier 2 emails. Also, they shouldn't be anon any more
  Then 2 emails should be delivered

  # user can now see claims

  When I follow "Log out"
    And I am logged in as "myname4"
  When I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
    And I follow "Show Claims"
  Then I should not see "Claimed by: myname4"
    And I should not see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"
  When I follow "Show Filled"
  Then I should see "Claimed by: myname4"
    And I should see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"
    
  # user claims an anon prompt

  When I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
  When I press "Claim"
  Then I should see "New claim made."

  # check that anon prompts are still anon on the claims index 
  
    And I should not see "myname2"
    And I should see "Claims (3)"
    
  # check that anon prompts are still anon on the prompts page
  
  When I follow "Prompts"
  Then I should not see "myname2" within "#main"
  
  # check that anon prompts are still anon on the user claims index
  When I am on my user page
    And I follow "My Claims"
  Then I should not see "myname2"
  
  # check that anon prompts are still anon on the claims show
  When I follow "Anonymous"
  Then I should not see "myname2"
    And I should see "Anonymous"
  
  # TODO: check that anon prompts are still anon on the fulfilling work
  
  # check that claims show as fulfilled
  
  When I follow "Log out"
    And I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
    
  # make another claim and then delete it
  
  When I follow "Log out"
    And I am logged in as "myname2"
    And I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should not see "Delete"
  When I follow "Prompts ("
  Then I should see "Claim"
  When I press "Claim"
  Then I should see "Delete"
  When I follow "Delete"
  Then I should see "Your claim was deleted."
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should not see "Delete"
  
  # make another claim and then delete it from the user claims list
  
  When I follow "Prompts ("
  Then I should see "Claim"
  When I press "Claim"
  Then I should see "Delete"
  When I am on my user page
    And I follow "My Claims"
  Then I should see "Delete"
  When I follow "Delete"
  Then I should see "Your claim was deleted."
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should not see "Delete"
  
  # make another claim and then fulfill from the post new form
  When I follow "Prompts ("
  Then I should see "Claim"
  When I press "Claim"
  Then I should see "New claim made"
  When I follow "Post New"
  When I fill in the basic work information for "Existing work"
    And I check "Battle 12 (Anonymous)"
    And I press "Preview"
  Then I should see "Draft was successfully created"
    And I should see "In response to a prompt by: Anonymous"
    # TODO: Figure out why there are still two emails
    And 2 emails should be delivered
    # TODO: Figure this out
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I view the work "Existing work"
  Then I should find "draft"
    
  # work left in draft so claim is not yet totally fulfilled
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname2" within "#fulfilled_claims"
    And I should see "Response posted on"
    And I should see "Not yet approved"
  When I follow "Response posted on"
  Then I should see "Existing work"
    And I should find "draft"
  When I am on my user page
    And I follow "My Drafts"
    And all emails have been delivered
  Then I should see "Existing work"
    And "Issue 2259" is fixed
    
  # post the draft and it is then fulfilled
  When I follow "Post Draft"
  Then 1 email should be delivered
  Then I should see "Your work was successfully posted"
    And I should see "In response to a prompt by: Anonymous"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname2" within "#fulfilled_claims"
    And I should see "Response posted on"
    # TODO: Figure this out
  #  And I should not see "Not yet approved"
  When I follow "Response posted on"
  Then I should see "Existing work"
    And I should not find "draft"
    
  # fulfill a claim from an existing work
  When I am logged out
    And I am logged in as "myname1"
    And I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "Claim"
  When I press "Claim"
  Then I should see "New claim made"
  When I post the work "Here's one I made earlier"
    And I edit the work "Here's one I made earlier"
    And I check "Battle 12 (Anonymous)"
    And I press "Preview"
  Then I should find "draft"
    And I should see "In response to a prompt by: Anonymous"
    # TODO: Figure this out
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should not find "draft"
    And I should see "In response to a prompt by: Anonymous"
  #TODO: Figure this one out, too
  #Then I should see "Collections:"
  #  And I should see "Battle 12"
    
  # work not left in draft so claim is fulfilled
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname1" within "#fulfilled_claims"
    And I should see "Response posted on"
    And I should see "Not yet approved"
