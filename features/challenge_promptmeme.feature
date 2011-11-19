@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Can create a collection to house a prompt meme
  
  Given I have standard challenge tags setup
  When I set up Battle 12 promptmeme collection
  Then I should be editing the challenge settings
  
  Scenario: Creating a prompt meme has different instructions from a gift exchange
  
  Given I have standard challenge tags setup
  When I set up Battle 12 promptmeme collection
  Then I should see prompt meme options
  
  Scenario: Create a prompt meme
  
  Given I have standard challenge tags setup
  When I create Battle 12 promptmeme
  Then Battle 12 prompt meme should be correctly created
  
  Scenario: User can see a prompt meme
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as a random user
  When I go to the collections page
  Then I should see "Battle 12"
  
  Scenario: Prompt meme is in list of open challenges
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as a random user
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
  
  Scenario: Can access settings from profile navigation
  
  Given I have Battle 12 prompt meme fully set up
  When I go to "Battle 12" collection's page
    And I follow "Profile"
  Then I should see "Challenge Settings" within ".navigation"
  When I follow "Challenge Settings" within ".navigation"
  Then I should be editing the challenge settings
  
  Scenario: Can edit settings for a prompt meme
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "mod1"
  When I edit settings for "Battle 12" challenge
  Then I should be editing the challenge settings
  
  Scenario: Signup being open is shown on profile
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as a random user
  When I go to "Battle 12" collection's page
    And I follow "Profile"
  Then I should see "Signup: Open"
  
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
    And I should see the whole signup
  
  Scenario: Sign up for a prompt meme and miss out some fields
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for "Battle 12" with missing prompts
  Then I should see "Request must have exactly 1 fandom tags. You currently have none."
  When I fill in the missing prompt
  Then I should see "Signup was successfully created"
  
  Scenario: Correct number of signups is shown in user sidebar
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my user page
  Then I should see "Signups (1)"
  
  Scenario: View signups in the dashboard
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my signups page
  Then I should see "Battle 12"

  Scenario: Prompt count shows on profile

  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I go to "Battle 12" collection's page
  # TODO: there is no more prompt count at all?
  # Then show me the main content
  Then I should see "Total prompts: 2"
    And I should see "Claimed prompts: 0"

  Scenario: Prompt count shows on collections index

  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I go to the collections page
  Then I should see "Prompts: 2"

  Scenario: Signups in the dashboard have correct controls
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my signups page
  Then I should see "Edit"
    And I should see "Delete"
  
  Scenario: Edit individual prompt via signup show
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I view my signup for "Battle 12"
  When I follow "Edit prompt"
  Then I should see single prompt editing
  And I should see "Edit whole signup"
 
 Scenario: Add one new prompt to existing signup
  
  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
    And I add a new prompt to my signup
  Then I should see "Prompt was successfully added"
    And I should see "Request 3"
    And I should see "My extra tag"
  
  Scenario: Sort prompts by date
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  And I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  When I view prompts for "Battle 12"
    And I follow "Date"
  Then I should see "Something else weird"
  
  Scenario: Sort prompts by fandom doesn't give error page
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  And I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  When I view prompts for "Battle 12"
    And I sort by fandom
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
  # TODO: there is no link to unposted claims anymore?
  When I view unposted claims for "Battle 12"
  Then I should see "Weird description"
  
  Scenario: Sort by fandom shouldn't show when there aren't any fandoms
  
  Given I have no-column prompt meme fully set up
  When I am logged in as "myname1"
    And I sign up for Battle 12 with combination E
    And I view prompts for "Battle 12"
  # TODO: We need to check the display for fandomless memes
  Then I should not see "sort"

  
  Scenario: Claim a prompt and view claims on main page and user page
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
  And I am logged in as "myname4"
  And I claim a prompt from "Battle 12"
  Then I should see a prompt is claimed

  Scenario: Claim count shows on profile

  Given I have Battle 12 prompt meme fully set up
    And I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
    And I claim a prompt from "Battle 12"
  When I go to "Battle 12" collection's page
  # TODO: have these been removed by design or by accident? and could we have them back?
  Then I should see "Total prompts: 2"
    And I should see "Claimed prompts: 1"
  
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
  Then I should see "othername"
  
  Scenario: User changes pseud on a challenge signup
  
  Given "myname1" has the pseud "othername"
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  Then I should see "Signup was successfully created"
    And I should see "Signup for myname1"
  When I edit my signup for "Battle 12"
  Then I should see "othername"
  When I select "othername" from "challenge_signup_pseud_id"
    # two forms in this page, must specify which button to press
    And I press "Update" 
  Then I should see "Signup was successfully updated"
  Then I should see "Signup for othername (myname1)"
  
  Scenario: Add more requests button disappears correctly from signup show page
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
  When I set up a basic promptmeme "Battle 12"
    And I follow "Challenge Settings"
  When I fill in multi-prompt challenge options
  When I sign up for Battle 12 with combination D
    And I add prompt 3
  Then I should see "Add another prompt"
  When I add prompt 4
  Then I should not see "Add another prompt"
    
  Scenario: Remove prompt button shouldn't show on Signups
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am on my user page
  When I follow "Signups"
  Then I should not see "Remove prompt"
  
  Scenario: Mod can't edit signups
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod1"
  When I edit the signup by "myname1"
  Then I should see "You can't edit someone else's signup"
  
  Scenario: Mod can't delete whole signups

  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod1"
  When I start to delete the signup by "myname1"
  Then I should see "myname1"
    And I should not see a link "myname1"
  
  Scenario: Mod deletes a prompt that doesn't fit the challenge rules
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I am logged in as "mod1"
  # TODO: mods can't delete prompts anymore?
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted"
    And I should see "Prompts for Battle 12"
    And I should not see "Signups for Battle 12"
  #  And "myname1" should be emailed
  
  Scenario: Mod cannot edit someone else's prompt TODO: hinkiness going on
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I am logged in as "mod1"
  When I edit the first prompt
  Then I should not see "Submit a Prompt for Battle 12"
    # And show me the main content
    And I should see "You can't edit someone else's prompt"

  Scenario: User can't delete prompt if they don't have enough

  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I delete the prompt by "myname1"
  Then I should see "That would make your signup invalid, sorry! Please edit instead."
  
  Scenario: User deletes one prompt
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
    And I add a new prompt to my signup for a prompt meme
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
    And I should see "by Anonymous"
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
    And I follow "Claims"
  Then I should see "Fulfilled Story"
   # TODO: should I? It's not there at all
    And I should not see "Not yet posted"
  
  Scenario: Claims count should be correct, shows fulfilled claims as well
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am on my user page
  # Then show me the sidebar # TODO: it has Claims (0) but why?
  Then I should see "Claims (1)"
  
  Scenario: Claim shows as fulfilled to another user
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination B
    And I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I fulfill my claim
  When I am logged in as "myname1"
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "Fulfilled By"
    And I should see "Mystery Work"
  # When I follow "Prompts ("
  #  And I follow "Show Claims"
  # Then I should not see "Claimed by: (Anonymous)"
  # When I follow "Show Filled"
  # Then I should see "Claimed by: (Anonymous) (Filled)"
    
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
  Then I should not see "myname4" within ".claims"
    And I should not see "mod1" within ".claims"
    And I should see "anonymous claimants" within ".claims"
  
  Scenario: User cannot see unposted claims to delete
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am logged in as "myname1"
  Then I should not see "Unposted Claims"
  
  Scenario: User can delete their own claim
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
    And I go to "Battle 12" collection's page
    And I follow "Your Claims"
    And I follow "Delete"
  Then I should see "Your claim was deleted."
  When I go to "Battle 12" collection's page
  Then I should not see "Your Claims"
  
  Scenario: User can delete their own claim from the user claims list
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am on my user page
    And I follow "Claims"
  Then I should see "Delete"
  When I follow "Delete"
  Then I should see "Your claim was deleted."
  # confirm claim no longer exists
  When I go to "Battle 12" collection's page
  Then I should not see "Your Claims"
  
  Scenario: Mod or owner can delete a claim from the user claims list
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I claim a prompt from "Battle 12"
  When I am logged in as "mod1"
    And I view unposted claims for "Battle 12"
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
  # work fulfilling is still fine
  When I view the work "Fulfilled Story"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    And I should not see "Stargate Atlantis"
    # work is still fine as another user
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
  
  Scenario: User claims two prompts in different challenges and fulfills both of them at once
  # TODO
  
  Scenario: Sign up for several challenges and see Signups are sorted
  
  Given I have Battle 12 prompt meme fully set up
  When I set up a basic promptmeme "Battle 13"
  When I set up an anon promptmeme "Battle 14" with name "anonmeme"
  When I am logged in as "prolific_writer"
  When I sign up for "Battle 12" fixed-fandom prompt meme
  When I sign up for "Battle 13" many-fandom prompt meme
  When I sign up for "Battle 14" many-fandom prompt meme
  When I am on my user page
    And I follow "Signups"
  # Then 14 should be the last signup in the table
  
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
    And I follow "post new"
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

  Scenario: As a co-moderator I can't delete whole signups

  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I start to delete the signup by "myname1"
  Then I should see "myname1"
    And I should not see a link "myname1"
  
  Scenario: As a co-moderator I can delete prompts

  Given I have Battle 12 prompt meme fully set up
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted."
  
  Scenario: When user deletes signup, its prompts disappear from the collection

  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I delete my signup for "Battle 12"
  When I view prompts for "Battle 12"
  Then I should not see "myname1"

  Scenario: When user deletes signup, as a prompter the signup disappears from my dashboard
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I delete my signup for "Battle 12"
  When I go to my signups page
  Then I should see "Signups (0)"
    And I should not see "Battle 12"

  Scenario: When user deletes signup, The story stays part of the collection, and no longer has the "In response to a prompt by:" line
  # TODO

  Scenario: When user deletes signup, As the story author I can edit the story normally
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
  Then I should see "Claims (0)"
  
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
  Then I should see "Claims (0)"
  
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
  Then I should see "Claims (1)" 
  When I follow "Claims"
  Then I should see "Your Claims"
    And I should not see "In Battle 12"
    And I should see "Writing For" within "#claims_table"
    And I should see "myname4" within "#claims_table"
  When I follow "Fulfill"
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
  Then I should see "Claims (1)"
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
    And I uncheck "This collection is unrevealed"
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
  When I view unposted claims for "Battle 12"
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
    And I follow "Claims"
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
    And I follow "Claims"
    And I follow "Anonymous"
  Then I should not see "myname4"
    And I should see "Anonymous"
    
  Scenario: check that anon prompts are still anon on the fulfilling work
  # TODO
  
  Scenario: Fulfilled claims show as fulfilled
  
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
  When I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
    And I follow "Claims"
  Then I should see "mod1" within "#fulfilled_claims"
    And I should see "myname4" within "#fulfilled_claims"
    
  Scenario: Make another claim and then fulfill from the post new form
  
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
  When I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
  When I follow "Prompts ("
  When I press "Claim"
  Then I should see "New claim made"
  When I follow "post new"
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
  
  Scenario: work left in draft so claim is not yet totally fulfilled
  
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
  When I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
  When I follow "Prompts ("
  When I press "Claim"
  When I follow "post new"
  When I fill in the basic work information for "Existing work"
    And I check "Battle 12 (Anonymous)"
    And I press "Preview"
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname4" within "#fulfilled_claims"
    And I should see "Response posted on"
    And I should see "Not yet approved"
  When I follow "Response posted on"
  Then I should see "Existing work"
    And I should find "draft"
  When I am on my user page
    And I follow "Drafts"
    And all emails have been delivered
  Then I should see "Existing work"
    And "Issue 2259" is fixed
    
  Scenario: When draft is posted, claim is fulfilled
  
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
  When I am logged in as "myname4"
    And I go to the collections page
    And I follow "Battle 12"
  When I follow "Prompts ("
  When I press "Claim"
  When I follow "post new"
  When I fill in the basic work information for "Existing work"
    And I check "Battle 12 (Anonymous)"
    And I press "Preview"
  When I am on my user page
    And I follow "Drafts"
    And all emails have been delivered
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
  
  Scenario: Fulfill a claim from an existing work
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I close signups for "Battle 12"
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname1"
    And I go to "Battle 12" collection's page
    And I follow "Prompts ("
  When I press "Claim"
  Then I should see "New claim made"
  When I post the work "Here's one I made earlier"
    And I edit the work "Here's one I made earlier"
    And I check "Battle 12"
    And I press "Preview"
  Then I should find "draft"
    And I should see "In response to a prompt by:"
    # TODO: Figure this out
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should not find "draft"
    And I should see "In response to a prompt by:"
  #TODO: Figure this one out, too
  #Then I should see "Collections:"
  #  And I should see "Battle 12"
    
  # work not left in draft so claim is fulfilled
  When I go to "Battle 12" collection's page
    And I follow "Claims"
  Then I should see "myname1" within "#fulfilled_claims"
    And I should see "Response posted on"

  Scenario: Download prompt CSV from signups page
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
    And I create Battle 12 promptmeme
  When I go to the "Battle 12" signups page
    And I follow "Download (CSV)"
  Then I should get a file with ending and type csv

  Scenario: Download prompt CSV from requests page # was the feature removed? why?
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
    And I create Battle 12 promptmeme
  When I go to the "Battle 12" requests page
    And I follow "Download (CSV)"
  Then I should get a file with ending and type csv
