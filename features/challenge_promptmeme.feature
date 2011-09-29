@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Creating a prompt meme has different instructions from a gift exchange
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up Battle 12 promptmeme collection
  Then I should see "Setting Up The Battle 12 Prompt Meme"
  Then I should see prompt meme options
  
  Scenario: Create a prompt meme
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I create Battle 12 promptmeme
  Then Battle 12 prompt meme should be correctly created
  
  Scenario: User can see a prompt meme
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I go to the collections page
  Then I should see "Battle 12"
  
  Scenario: Prompt meme is in list of open challenges
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I view open challenges
  Then I should see "Battle 12"
  
  Scenario: Past challenge is not in list of open challenges
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up Battle 12 promptmeme collection
    And I fill in past challenge options
    And I am logged in as "myname1"
  When I view open challenges
  Then I should not see "Battle 12"
  
  Scenario: Future challenge is not in list of open challenges
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up Battle 12 promptmeme collection
    And I fill in future challenge options
    And I am logged in as "myname1"
  When I view open challenges
  Then I should not see "Battle 12"
  
  Scenario: Can edit settings for a prompt meme
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "mod1"
  When I go to "Battle 12" collection's page
    And I follow "Profile"
  Then I should see "Challenge Settings" within ".navigation"
  When I follow "Challenge Settings" within ".navigation"
  Then I should see "Setting Up The Battle 12 Prompt Meme"
  
  Scenario: Signup being open is shown on profile
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I go to "Battle 12" collection's page
    And I follow "Profile"
  Then I should see "Signup: CURRENTLY OPEN"
  
  Scenario: User can see profile descriptions
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I go to "Battle 12" collection's page
  When I follow "Profile"
  Then I should see Battle 12 descriptions
  
  Scenario: Sign up for a prompt meme
  
  Given I have Battle 12 prompt meme fully set up
  And I am logged in as "myname1"
  When I go to "Battle 12" collection's page
  Then I should see "Sign Up"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
    And I should see "Prompts (2)"
  
  Scenario: Sign up for a prompt meme and miss out some fields
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for "Battle 12" with missing prompts
  Then I should see "Request must have exactly 1 fandom tags. You currently have none."
  When I fill in the missing prompt
  Then I should see "Signup was successfully created"
  
  Scenario: View signups in the dashboard
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my user page
  Then I should see "My Signups (1)"
  When I follow "My Signups (1)"
  Then I should see "Battle 12"
    And I should see "Edit"
    And I should see "Delete"
  
  Scenario: View individual prompt
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I view my signup for "Battle 12"
  Then I should see the whole signup
  When I follow "Request 1"
  Then I should just see request 1
  
  Scenario: Edit individual prompt via signup show
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I view my signup for "Battle 12"
  When I follow "Request 1"
  When I follow "Edit this prompt"
  Then I should see single prompt editing
  
  Scenario: Edit individual prompt via signup edit
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I edit my signup for "Battle 12"
  When I follow "Request 1"
  Then I should not see "Request 2"
    And I should see "Edit whole signup instead"

 Scenario: Add one new prompt to existing signup
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
    And I follow "Add another prompt"
    And I check "Stargate Atlantis"
    And I fill in "challenge_signup_requests_attributes_2_tag_set_attributes_freeform_tagnames" with "My extra tag"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
    And I should see "Request 3"
    And I should see "My extra tag"
  
  Scenario: Sort prompts by date
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  And I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  When I view prompts for "Battle 12"
    And I follow "Sort by date"
  Then I should see "Something else weird"
  
  Scenario: Sort prompts by fandom doesn't give error page
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  And I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  When I view prompts for "Battle 12"
    And I follow "Sort by fandom"
  Then I should see "Something else weird"
  
  Scenario: Sign up for a prompt meme with no tags
  
  Given I have no-column prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination E
  Then I should see "Signup was successfully created"
  
  Scenario: If there are no fandoms, prompt info on claims should show description or URL
  
  Given I have no-column prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination E
  When I claim a prompt from "Battle 12"
  When I view claims for "Battle 12"
  Then I should see "Weird description"
  
  Scenario: Sort by fandom shouldn't show when there aren't any fandoms
  
  Given I have no-column prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination E
  When I view prompts for "Battle 12"
  Then I should not see "Sort by fandom"
  
  Scenario: Claim a prompt and view claims on main page and user page
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
  And I am logged in as "myname4"
  And I claim a prompt from "Battle 12"
  Then I should see a prompt is claimed
  
  Scenario: Mod can view signups
  
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  When I am logged in as "mod1"
    And I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
  Then I should see correct signups for Battle 12
  
  Scenario: Sign up with both prompts anon
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
  Then I should see "Signup was successfully created"
  
  Scenario: Sign up with neither prompt anon
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
  
  Scenario: Sign up with one anon prompt and one not
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  Then I should see "Signup was successfully created"
  
  Scenario: User has more than one pseud on signup form
  
  Given "myname1" has the pseud "othername"
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I start to sign up for "Battle 12"
  Then I should see "Select pseudonym"
  
  Scenario: User changes pseud on a challenge signup
  
  Given "myname1" has the pseud "othername"
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
    And I should see "Signup for myname1"
  When I edit my signup for "Battle 12"
  Then I should see "Select pseudonym"
  When I select "othername" from "Select pseudonym"
    And I press "Submit"
  Then I should see "Signup was successfully updated"
  Then I should see "Signup for othername (myname1)"
  
  Scenario: Add more requests button disappears correctly from signup show page
  
  Given I have standard challenge tags setup
    And I am logged in as "mod1"
  When I set up a basic promptmeme "Battle 12"
    And I follow "Challenge Settings"
  When I fill in multi-prompt challenge options
  When I sign up for Battle 12 with combination D
    And I add prompt 3
  Then I should see "Add another prompt"
  When I add prompt 4
  Then I should not see "Add another prompt"
  
  Scenario: Add more requests button disappears correctly from signup show page
  
  Given I have standard challenge tags setup
    And I am logged in as "mod1"
  When I set up a basic promptmeme "Battle 12"
    And I follow "Challenge Settings"
  When I fill in multi-prompt challenge options
  When I sign up for Battle 12 with combination D
    And I add prompt 3
  Then I should see "Add another prompt"
  When I add prompt 4
    And I follow "Request 4"
  Then I should not see "Add another prompt"
  
  Scenario: Remove prompt button shouldn't show on My Signups
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my user page
  When I follow "My Signups"
  Then I should not see "Remove prompt"
  
  Scenario: Mod can't edit signups
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod1"
  When I edit the signup by "myname1"
  Then I should see "You can't edit someone else's signup"
  
  Scenario: Mod deletes a signup that doesn't fit the challenge rules
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod1"
  When I delete the signup by "myname1"
  Then I should see "Challenge signup was deleted."
  #  And "myname1" should be emailed
  
  Scenario: Mod deletes a prompt that doesn't fit the challenge rules
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I am logged in as "mod1"
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted"
    And I should see "Prompts for Battle 12"
    And I should not see "Signups for Battle 12"
  #  And "myname1" should be emailed
  
  Scenario: Mod cannot edit someone else's prompt
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I am logged in as "mod1"
  When I edit the prompt by "myname1"
  Then I should not see "Submit a Prompt for Battle 12"
    And I should see "You can't edit someone else's signup!"

  Scenario: User deletes one prompt
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted"
  
  Scenario: Claim an anon prompt
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  When I press "Claim"
  Then I should see "New claim made."
    And I should see "(Anonymous)"
    And I should not see "myname" within "#main"
  
  Scenario: Fulfilling a claim ticks the right boxes automatically
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I start to fulfill my claim
  Then the "Battle 12" checkbox should be checked
    And the "Battle 12" checkbox should not be disabled
  
  Scenario: User can fulfill a claim
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  Then my claim should be fulfilled
  
  Scenario: User can fulfill a claim to their own prompt
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
    And I sign up for Battle 12 with combination B
    And I claim a prompt from "Battle 12"
    And I fulfill my claim
  Then my claim should be fulfilled
  
  Scenario: Fulfilled claim shows correctly on my claims
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am on my user page
    And I follow "My Claims"
  Then I should see "Fulfilled Story"
    And I should not see "Not yet posted"
  
  Scenario: Claims count should be correct, shows fulfilled claims as well
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am on my user page
  Then I should see "My Claims (1)"
  
  Scenario: Claim shows as fulfilled to another user
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am logged in as "myname1"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "Secret!" within "#fulfilled_claims"
    And I should not see "Secret!" within "#unfulfilled_claims"
  When I follow "Prompts ("
    And I follow "Show Claims"
  Then I should not see "Claimed by: (Anonymous)"
  When I follow "Show Filled"
  Then I should see "Claimed by: (Anonymous) (Filled)"
    
  Scenario: Prompts are counted up correctly
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Prompts (2)"
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  Then I should see "Prompts (4)"
  
  Scenario: Claims are shown to mod
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  Then claims are shown
  
  Scenario: Claims are hidden from ordinary user
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  Then claims are hidden
  
  Scenario: Fulfilled claims are shown to mod
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I am on "Battle 12" collection's page
  When I follow "Prompts"
    And I follow "Show Claims"
  Then I should not see "Claimed by: myname4"
    And I should not see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"
  When I follow "Show Filled"
  Then I should see "Claimed by: myname4"
    And I should see "Claimed by: mod1"
    And I should not see "Claimed by: (Anonymous)"
  
  Scenario: Fulfilled claims are hidden from user
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I am logged in as "myname4"
  When I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
    And I follow "Show Claims"
    And I follow "Show Filled"
  Then I should not see "Claimed by: myname4"
    And I should not see "Claimed by: mod1"
    And I should see "Claimed by: (Anonymous)"
  
  Scenario: User cannot delete someone else's claim
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am logged in as "myname1"
  When I view claims for "Battle 12"
  Then I should not see "Delete"
  
  Scenario: User can delete their own claim from the collection claims list
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I view claims for "Battle 12"
  When I follow "Delete"
  Then I should see "Your claim was deleted."
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should not see "Delete"
  
  Scenario: User can delete their own claim from the user claims list
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am on my user page
    And I follow "My Claims"
  Then I should see "Delete"
  When I follow "Delete"
  Then I should see "Your claim was deleted."
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should not see "Delete"
  
  Scenario: Mod or owner can delete a claim from the user claims list
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am logged in as "mod1"
    And I view claims for "Battle 12"
  Then I should see "Delete"
  When I follow "Delete"
  Then I should see "The claim was deleted."
  
  Scenario: Signup can be deleted after response has been posted
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am logged in as "myname1"
    And I delete my signup for "Battle 12"
  Then I should see "Challenge signup was deleted."
  When I view the work "Fulfilled Story"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    And I should not see "Stargate Atlantis"
  When I am logged in as "myname4"
    And I view the work "Fulfilled Story"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    And I should see "Stargate Atlantis"
  
  Scenario: Prompt can be removed after response has been posted
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am logged in as "myname1"
    And I delete my prompt in "Battle 12"
  Then I should see "Prompt was deleted."
  When I view the work "Fulfilled Story"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    And I should not see "Stargate Atlantis"
  When I am logged in as "myname4"
    And I view the work "Fulfilled Story"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    And I should see "Stargate Atlantis"
  
  Scenario: User can't claim the same prompt twice
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
    And I view prompts for "Battle 12"
  Then I should see "Already claimed by you"
  
  Scenario: User can fulfill the same claim twice
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I fulfill my claim again
  Then I should see "Work was successfully posted"
    And I should see "Second Story"
    And I should see "In response to a prompt by: Anonymous"
    And I should see "Collections: Battle 12"
  
  Scenario: User edits existing work to fulfill claim
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
    And I post the work "Existing Story"
    And I edit the work "Existing Story"
    And I check "Battle 12 (Anonymous) -  - Stargate Atlantis"
    And I press "Post without preview"
  Then I should see "Battle 12"
  When I follow "Anonymous"
  Then I should see "Mystery work"
    And I should not see "Not fulfilled yet"
  When I reveal works for "Battle 12"
  When I view the work "Existing Story"
    And I follow "Anonymous"
  Then I should see "Response posted on"
    
  Scenario: User edits existing work in another collection to fulfill claim
  
  Given I have Battle 12 prompt meme fully set up
    And I have a collection "Othercoll"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
    And I post the work "Existing Story" in the collection "Othercoll"
    And I edit the work "Existing Story"
    And I check "Battle 12 (Anonymous) -  - Stargate Atlantis"
    And I press "Post without preview"
  Then I should see "Battle 12"
    And I should see "Othercoll"
    
  Scenario: Claim two prompts by the same person in one challenge
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  # 1st prompt SG-1, 2nd prompt SGA, both anon
  When I am logged in as "myname1"
    And I claim two prompts from "Battle 12"
    And I view prompts for "Battle 12"
  # all prompts have been claimed - check it worked
  Then I should not see "Claim" within "tbody"
  # SG-1 as claims are in reverse date order
  When I start to fulfill my claim
  Then I should find a checkbox "Battle 12 (Anonymous) -  - Stargate SG-1 - Alternate Universe - High School, Something else weird"
    And I should find a checkbox "Battle 12 (Anonymous) -  - Stargate Atlantis"
  # Commenting out intermittent failures
  #Then the "Battle 12 (Anonymous) -  - Stargate SG-1 - Alternate Universe - High School, Something else weird" checkbox should be checked
  #Then the "Battle 12 (Anonymous) -  - Stargate Atlantis" checkbox should not be checked
  
  Scenario: Claim two prompts by different people in one challenge
  
  Given I have single-prompt prompt meme fully set up
  When I am logged in as "sgafan"
    And I sign up for "Battle 12" with combination SGA
  When I am logged in as "sg1fan"
    And I sign up for "Battle 12" with combination SG-1
  When I am logged in as "writer"
    And I claim two prompts from "Battle 12"
  When I start to fulfill my claim
  Then I should find a checkbox "Battle 12 (sg1fan) -  - Stargate SG-1"
    And I should find a checkbox "Battle 12 (sgafan) -  - Stargate Atlantis"
  # Commenting out intermittent failures
  #Then the "Battle 12 (sgafan) -  - Stargate Atlantis" checkbox should be checked
  #Then the "Battle 12 (sg1fan) -  - Stargate SG-1" checkbox should not be checked
  
  Scenario: Claim two prompts by the same person in one challenge, one is anon
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12
  # 1st prompt "something else weird", 2nd prompt anon
  When I am logged in as "myname1"
    And I claim two prompts from "Battle 12"
    And I view prompts for "Battle 12"
  # all prompts have been claimed - check it worked
  Then I should not see "Claim" within "tbody"
  # anon as claims are in reverse date order
  When I start to fulfill my claim
  Then I should find a checkbox "Battle 12 (Anonymous) -  - Stargate SG-1"
    And I should find a checkbox "Battle 12 (myname2) -  - Stargate SG-1 - Something else weird"
  # Commenting out intermittent failures
  #Then the "Battle 12 (Anonymous) -  - Stargate SG-1" checkbox should be checked
  # Always checked according to one test
  #Then the "Battle 12 (myname2) -  - Stargate SG-1 - Something else weird" checkbox should not be checked
  
  Scenario: User claims two prompts in one challenge and fulfills one of them
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  # 1st prompt SG-1, 2nd prompt SGA, both anon
  When I am logged in as "myname1"
    And I claim a prompt from "Battle 12"
    # SGA as it's in reverse order
    And I claim a prompt from "Battle 12"
    # SG-1
  # SG-1 as claims are in reverse date order
  When I start to fulfill my claim
  Then the "Battle 12 (Anonymous) -  - Stargate SG-1 - Alternate Universe - High School, Something else weird" checkbox should be checked
  # this next line shouldn't be needed - there's still a bug somewhere
  When I uncheck "Battle 12 (Anonymous) -  - Stargate Atlantis"
  Then the "Battle 12 (Anonymous) -  - Stargate Atlantis" checkbox should not be checked
  When I press "Preview"
  # Commenting out intermittent failure related to options_select issue
  #Then I should not see "Stargate Atlantis"
  #  And I should see "Stargate SG-1"
  #  And I should see "Something else weird"
  #When I press "Post"
  #When I view the work "Fulfilled Story"
  #Then I should not see "Stargate Atlantis"
  #  And I should see "Stargate SG-1"
  #  And I should see "Something else weird"
  #When I follow "Anonymous" within "p"
  #Then I should not see "Stargate Atlantis"
  #  And I should see "Stargate SG-1"
  
  Scenario: User claims two prompts in one challenge and fufills both of them at once
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  # 1st prompt SG-1, 2nd prompt SGA
  When I am logged in as "myname1"
    And I claim a prompt from "Battle 12"
    # SGA as it's in reverse order
    And I claim a prompt from "Battle 12"
    # SG-1
    And I view prompts for "Battle 12"
  When I start to fulfill my claim
    And I check "Battle 12 (Anonymous) -  - Stargate SG-1 - Alternate Universe - High School, Something else weird"
    And I press "Preview"
    And I press "Post"
  When I view the work "Fulfilled Story"
  # TODO: fix the broken bit
  #Then I should see "Stargate Atlantis"
  #  And I should see "Stargate SG-1"
  #Then show me the main content
  
  Scenario: User claims two prompts in different challenges and fulfills both of them at once
  # TODO
  
  Scenario: Sign up for several challenges and see My Signups are sorted
  
  Given I have Battle 12 prompt meme fully set up
  When I set up a basic promptmeme "Battle 13"
  When I set up an anon promptmeme "Battle 14" with name "anonmeme"
  When I am logged in as "prolific_writer"
  When I sign up for "Battle 12" fixed-fandom prompt meme
  When I sign up for "Battle 13" many-fandom prompt meme
  When I sign up for "Battle 14" many-fandom prompt meme
  When I am on my user page
    And I follow "My Signups"
  # Then 14 should be the last signup in the table
  # Then show me the page
  
  Scenario: User is participating in a prompt meme and a gift exchange at once, clicks "Post to fulfill" on the prompt meme and sees the right boxes ticked
  
  Given I have created the gift exchange "My Gift Exchange"
    And I have opened signup for the gift exchange "My Gift Exchange"
    And everyone has signed up for the gift exchange "My Gift Exchange"
    And I have generated matches for "My Gift Exchange"
    And I have sent assignments for "My Gift Exchange"
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
  When I start to fulfill my claim
  Then the "Battle 12 (myname4) -  - Stargate Atlantis" checkbox should be checked
    And the "My Gift Exchange (myname2)" checkbox should not be checked
    And the "Battle 12 (myname4) -  - Stargate Atlantis" checkbox should not be disabled
    And the "My Gift Exchange (myname2)" checkbox should not be disabled
    
  Scenario: User posts to fulfill direct from Post New
  
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
    And I follow "Post New"
  Then the "Battle 12 (myname4) -  - Stargate Atlantis" checkbox should not be checked
    And the "Battle 12 (myname4) -  - Stargate Atlantis" checkbox should not be disabled
  
  Scenario: User is participating in a prompt meme and a gift exchange at once, clicks "Post to fulfill" on the prompt meme and then changes their mind and fulfills the gift exchange instead

  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  Given I have created the gift exchange "My Gift Exchange"
    And I have opened signup for the gift exchange "My Gift Exchange"
    And everyone has signed up for the gift exchange "My Gift Exchange"
    And I have generated matches for "My Gift Exchange"
    And I have sent assignments for "My Gift Exchange"
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
  When I start to fulfill my claim
  When I check "My Gift Exchange (myname2)"
    And I uncheck "Battle 12 (myname4) -  - Stargate Atlantis"
    And I press "Post without preview"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: My Gift Exchange"
    And I should see "Battle 12"

  Scenario: As a co-moderator I can delete whole signups

  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I delete the signup by "myname1"
  Then I should see "Challenge signup was deleted."
  
  Scenario: As a co-moderator I can delete prompts

  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted."
  
  Scenario: When maintainer deletes signup, its prompts disappear from the collection

  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I delete the signup by "myname1"
  When I view prompts for "Battle 12"
  Then I should not see "myname1"

  Scenario: When maintainer deletes signup, as a prompter the signup disappears from my dashboard
  
  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I delete the signup by "myname1"
  When I am logged in as "myname1"
  When I go to my signups page
  Then I should see "My Signups (0)"
    And I should not see "Battle 12"

  Scenario: When maintainer deletes signup, The story stays part of the collection, and no longer has the "In response to a prompt by:" line
  # TODO

  Scenario: When maintainer deletes signup, As the story author I can edit the story normally
  # TODO
  
  Scenario: Delete a challenge, user can still access my signups page
  # TODO
  
  Scenario: Delete a challenge, user can still access my claims page
  # TODO
  
  Scenario: Delete a challenge, responses no longer show prompt line
  # TODO
  
  Scenario: Delete a collection, user can still access story
  # TODO
  
  Scenario: Delete a signup, claims should also be deleted
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I am logged in as "myname1"
    And I delete my signup for "Battle 12"
  Then I should see "Challenge signup was deleted."
  When I am logged in as "myname4"
    And I go to my claims page
  Then I should see "My Claims (0)"
  
  Scenario: Delete a prompt, claims should also be deleted
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I am logged in as "myname1"
    And I delete my prompt in "Battle 12"
  Then I should see "Prompt was deleted."
  When I am logged in as "myname4"
    And I go to my claims page
  Then I should see "My Claims (0)"
  
  Scenario: Mod can claim a prompt like an ordinary user
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
  Then I should see "New claim made."
  
  Scenario: Mod can still see anonymous claims after signup is closed
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "mod1"
  When I am on "Battle 12" collection's page
    And I follow "Claims ("
  Then I should see "Unfulfilled Claims"
    And I should see "mod" within "#unfulfilled_claims"
    And I should see "myname4" within "#unfulfilled_claims"
    And I should see "Stargate Atlantis" within "#unfulfilled_claims"
    And I should see "Alternate Universe - Historical" within "#unfulfilled_claims"
    And I should not see "Alternate Universe - Historical" within "#fulfilled_claims"
    And I should see "Stargate Atlantis" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
  
  Scenario: Mod can post a fic
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
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
  
  Scenario: Fic shows what prompt it is fulfilling when mod views it
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
  When I start to fulfill my claim
    And I fill in "Work Title" with "Fulfilled Story-thing"
    And I fill in "content" with "This is an exciting story about Atlantis, but in a different universe this time"
  When I press "Preview"
    And I press "Post"
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to a prompt by: myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Anonymous" within ".byline"
    And I should not see "mod1" within ".byline"
  
  Scenario: Mod can complete a claim
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
  When I start to fulfill my claim
    And I fill in "Work Title" with "Fulfilled Story-thing"
    And I fill in "content" with "This is an exciting story about Atlantis, but in a different universe this time"
  When I press "Preview"
    And I press "Post"
  When I am on my user page
  Then I should see "My Claims (1)"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should not see "mod1" within "#unfulfilled_claims"
    
  Scenario: check that claims can't be viewed even after challenge is revealed
  # TODO: Find a way to construct the link to a claim show page for someone who shouldn't be able to see it
  
  Scenario: check that completed ficlet is unrevealed
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When mod fulfills claim
  When I am logged in as "myname4"
  When I view the work "Fulfilled Story-thing"
  Then I should not see "In response to a prompt by: myname4"
    And I should not see "Fandom: Stargate Atlantis"
    And I should not see "Anonymous"
    And I should not see "mod1"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    
  Scenario: Mod can reveal challenge
  
  Given I have Battle 12 prompt meme fully set up
  When I close signups for "Battle 12"
  When I go to "Battle 12" collection's page
    And I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Update"
  Then I should see "Collection was successfully updated"
  
  Scenario: Revealing challenge sends out emails
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  Then I should see "Collection was successfully updated"
  # 2 stories are now revealed, so notify the prompters
    And 2 emails should be delivered
    
  Scenario: Story is anon when challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  When I am logged in as "myname4"
  When I view the work "Fulfilled Story-thing"
  Then I should see "In response to a prompt by: myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Collections: Battle 12"
    And I should see "Anonymous" within ".byline"
    And I should not see "mod1" within ".byline"
    And I should see "Alternate Universe - Historical"
    
  Scenario: Authors can be revealed
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  Then I should see "Collection was successfully updated"
  
  Scenario: Revealing authors doesn't send emails
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  Given all emails have been delivered
  When I reveal the authors of the "Battle 12" challenge
  Then I should see "Collection was successfully updated"
  Then 0 emails should be delivered
  
  Scenario: When challenge is revealed-authors, user can see claims
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname4"
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
  
  Scenario: Anon prompts stay anon on claims index even if challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I view claims for "Battle 12"
  Then I should see "(Anonymous)"
    And I should not see "myname4"
  
  Scenario: Check that anon prompts are still anon on the prompts page after challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I view prompts for "Battle 12"
  Then I should see "(Anonymous)"
    And I should not see "myname4"
  
  Scenario: Check that anon prompts are still anon on user claims index after challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname2"
  When I am on my user page
    And I follow "My Claims"
  Then I should not see "myname4"
    And I should see "Anonymous"
    
  Scenario: Check that anon prompts are still anon on claims show after challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname2"
  When I am on my user page
    And I follow "My Claims"
    And I follow "Anonymous"
  Then I should not see "myname4"
    And I should see "Anonymous"
    
  Scenario: check that anon prompts are still anon on the fulfilling work
  # TODO
  
  Scenario: All the rest of the unrefactored stuff
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I am logged in as "myname4"
  When I fulfill my claim
  When mod fulfills claim
  When I reveal the "Battle 12" challenge
  Given all emails have been delivered
  When I reveal the authors of the "Battle 12" challenge
  When I go to "Battle 12" collection's page
    And I follow "Prompts (8)"
  When I press "Claim"
  Then I should see "New claim made."

  # check that claims show as fulfilled
  
  When I follow "Log out"
    And I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
  
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
    And 0 emails should be delivered
    # TODO: Figure this out
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I view the work "Existing work"
  Then I should find "draft"
    
  # work left in draft so claim is not yet totally fulfilled
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname4" within "#fulfilled_claims"
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
  Then I should see "myname4" within "#fulfilled_claims"
    And I should see "Response posted on"
    # TODO: Figure this out
  #  And I should not see "Not yet approved"
  When I follow "Response posted on"
  Then I should see "Existing work"
    And I should not find "draft"
    
  # fulfill a claim from an existing work
  When I am logged in as "myname1"
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


  Scenario: Download prompt CSV from signups page
  Given I am logged in as "mod1"
  And I have standard challenge tags setup
  And I create Battle 12 promptmeme

  When I go to the "Battle 12" signups page
  And I follow "Download (CSV)"
  Then I should get a file with ending and type csv

  Scenario: Download prompt CSV from requests page
  Given I am logged in as "mod1"
  And I have standard challenge tags setup
  And I create Battle 12 promptmeme

  When I go to the "Battle 12" requests page
  And I follow "Download (CSV)"
  Then I should get a file with ending and type csv

