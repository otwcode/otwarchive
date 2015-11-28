@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want to create a prompt meme and post to it
  
  Scenario: Claim two prompts by the same person in one challenge
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  # 1st prompt SG-1, 2nd prompt SGA, both anon
  When I am logged in as "myname1"
    And I claim two prompts from "Battle 12"
    And I view prompts for "Battle 12"
  # all prompts have been claimed - check it worked
  # TODO: find a better way to check that it worked, since 'Drop Claim' includes the word 'Claim', and there is no table anymore, so no tbody
  # Then I should not see "Claim" within "tbody"
  # TODO: check that they are not intermittent anymore
  When I start to fulfill my claim
  Then I should find a checkbox "High School AU SG1 in Battle 12 (Anonymous)"
    And I should find a checkbox "random SGA love in Battle 12 (Anonymous)"
    And the "High School AU SG1 in Battle 12 (Anonymous)" checkbox should not be checked
    And the "random SGA love in Battle 12 (Anonymous)" checkbox should be checked
  
  Scenario: Claim two prompts by different people in one challenge
  
  Given I have single-prompt prompt meme fully set up
  When I am logged in as "sgafan"
    And I sign up for "Battle 12" with combination SGA
  When I am logged in as "sg1fan"
    And I sign up for "Battle 12" with combination SG-1
  When I am logged in as "writer"
    And I claim two prompts from "Battle 12"
  When I start to fulfill my claim
  Then I should find a checkbox "SG1 love in Battle 12 (sg1fan)"
    And I should find a checkbox "SGA love in Battle 12 (sgafan)"
  # TODO: check that they are not intermittent anymore
    And the "SGA love in Battle 12 (sgafan)" checkbox should not be checked
    And the "SG1 love in Battle 12 (sg1fan)" checkbox should be checked
  
  Scenario: Claim two prompts by the same person in one challenge, one is anon
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12
  # 1st prompt "something else weird" and titled "crack", 2nd prompt anon
  When I am logged in as "myname1"
    And I claim two prompts from "Battle 12"
    And I view prompts for "Battle 12"
  # anon as claims are in reverse date order
  When I start to fulfill my claim
  Then I should find a checkbox "Untitled Prompt in Battle 12 (Anonymous)"
    And I should find a checkbox "crack in Battle 12 (myname2)"
    And the "Untitled Prompt in Battle 12 (Anonymous)" checkbox should be checked
    And the "crack in Battle 12 (myname2)" checkbox should not be checked
  
  Scenario: User claims two prompts in one challenge and fulfills one of them
  # TODO: When SPRs get merged, make this check that 'prompt' is a link
  # and that it shows the correct prompt, or whatever
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12 with combination B
  # 1st prompt SG-1, 2nd prompt SGA, both anon
  When I am logged in as "myname1"
    And I claim a prompt from "Battle 12"
    # SGA as it's in reverse order
    And I claim a prompt from "Battle 12"
    # SG-1
  # SGA seems to be the first consistently
  When I start to fulfill my claim
  Then the "High School AU SG1 in Battle 12 (Anonymous)" checkbox should not be checked
    And the "random SGA love in Battle 12 (Anonymous)" checkbox should be checked
  When I press "Preview"
    And I press "Post"
  When I view the work "Fulfilled Story"
  Then I should see "Stargate Atlantis"
  
  Scenario: User claims two prompts in one challenge and fufills both of them at once
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
  When I sign up for Battle 12
  # 1st prompt anon, 2nd prompt non-anon
  When I am logged in as "myname1"
    And I claim a prompt from "Battle 12"
    And I claim a prompt from "Battle 12"
    And I view prompts for "Battle 12"
  When I start to fulfill my claim
  # the anon prompt will already by checked
    And I check "crack in Battle 12 (myname2)"
    And I press "Preview"
    And I press "Post"
  When I view the work "Fulfilled Story"
  # fandoms are not filled in automatically anymore, so we check that both prompts are marked as filled by having one anon and one non-anon
  Then I should see "In response to a prompt by Anonymous"
    And I should see "In response to a prompt by myname2"
  
  Scenario: User claims two prompts in different challenges and fulfills both of them at once
  # TODO
  
  Scenario: Sign up for several challenges and see Sign-ups are sorted
  
  Given I have Battle 12 prompt meme fully set up
  When I set up a basic promptmeme "Battle 13"
  When I set up an anon promptmeme "Battle 14" with name "anonmeme"
  When I am logged in as "prolific_writer"
  When I sign up for "Battle 12" fixed-fandom prompt meme
  When I sign up for "Battle 13" many-fandom prompt meme
  When I sign up for "Battle 14" many-fandom prompt meme
  When I am on my user page
    And I follow "Sign-ups"
  # TODO
  
  Scenario: User is participating in a prompt meme and a gift exchange at once, clicks "Post to fulfill" on the prompt meme and sees the right boxes ticked
  
  Given I have created the gift exchange "My Gift Exchange"
    And I open signups for "My Gift Exchange"
    And everyone has signed up for the gift exchange "My Gift Exchange"
    And I have generated matches for "My Gift Exchange"
    And I have sent assignments for "My Gift Exchange"
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
  When I start to fulfill my claim
  Then the "canon SGA love in Battle 12 (myname4)" checkbox should be checked
    And the "My Gift Exchange (myname2)" checkbox should not be checked
    And the "canon SGA love in Battle 12 (myname4)" checkbox should not be disabled
    And the "My Gift Exchange (myname2)" checkbox should not be disabled
    
  Scenario: User posts to fulfill direct from Post New (New Work)
  
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
    And I follow "New Work"
  Then the "canon SGA love in Battle 12 (myname4)" checkbox should not be checked
    And the "canon SGA love in Battle 12 (myname4)" checkbox should not be disabled
  
  Scenario: User is participating in a prompt meme and a gift exchange at once, clicks "Post to fulfill" on the prompt meme and then changes their mind and fulfills the gift exchange instead

  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
  Given I have created the gift exchange "My Gift Exchange"
    And I open signups for "My Gift Exchange"
    And everyone has signed up for the gift exchange "My Gift Exchange"
    And I have generated matches for "My Gift Exchange"
    And I have sent assignments for "My Gift Exchange"
  When I am logged in as "myname3"
    And I claim a prompt from "Battle 12"
  When I start to fulfill my claim
  When I check "My Gift Exchange (myname2)"
    And I uncheck "canon SGA love in Battle 12 (myname4)"
    And I fill in "Post to Collections / Challenges" with ""
    And I press "Post Without Preview"
  Then I should see "My Gift Exchange"
    And I should not see "Battle 12"
    And I should not see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: My Gift Exchange"

  Scenario: As a co-moderator I can't delete whole signups

  Given I have Battle 12 prompt meme fully set up
  # TODO: fix the form in the partial collection_participants/participant_form
  # TODO: we allow maintainers to delete whole sign-ups
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I am logged in as "mod2"
  When I start to delete the signup by "myname1"
  Then I should see "myname1"
    And I should not see a link "myname1"
  
  Scenario: As a co-moderator I can delete prompts

  Given I have Battle 12 prompt meme fully set up
  # TODO: fix the form in the partial collection_participants/participant_form and make sure the moderator is a real mod. Can't delete prompts because there are only 2 and so are not allowed to be deleted (needs to be three)
  Given I have added a co-moderator "mod2" to collection "Battle 12"
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination C
  When I add a new prompt to my signup for a prompt meme
  When I am logged in as "mod2"
  When I delete the prompt by "myname1"
  Then I should see "Prompt was deleted."
  
  Scenario: When user deletes signup, its prompts disappear from the collection

  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I delete my signup for the prompt meme "Battle 12"
  When I view prompts for "Battle 12"
  Then I should not see "myname1" within "ul.index"

  Scenario: When user deletes signup, as a prompter the signup disappears from my dashboard
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
  When I sign up for Battle 12 with combination A
  When I delete my signup for the prompt meme "Battle 12"
  When I go to my signups page
  Then I should see "Sign-ups (0)"
    And I should not see "Battle 12"

  Scenario: When user deletes signup, The story stays part of the collection, and no longer has the "In response to a prompt by" line
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
    And I delete my signup for the prompt meme "Battle 12"
  Then I should see "Challenge sign-up was deleted."
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
    And I delete my signup for the prompt meme "Battle 12"
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
    And I follow "Unposted Claims ("
  Then I should see "claimed by mod"
    And I should see "by myname4"
    And I should see "Stargate Atlantis"
  
  Scenario: Mod can post a fic
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I am logged in as "mod1"
  When I claim a prompt from "Battle 12"
  When I am on my user page
  Then I should see "Claims (1)" 
  When I follow "Claims"
  Then I should see "My Claims"
    And I should see "canon SGA love by myname4 in Battle 12" within "div#main.challenge_claims-index h4"
  When I follow "Fulfill"
    And I fill in "Fandoms" with "Stargate Atlantis"
    And I fill in "Work Title*" with "Fulfilled Story-thing"
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
  Then I should see "In response to a prompt by myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Anonymous" within ".byline"
  
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
  Then I follow "Claims"
    And I should not see "mod" within "h4"
  Then I follow "Fulfilled Claims"
  # On the users' My Claims page, they see their anon works as Anonymous
    And I should see "Anonymous" within "div.work h4"
  
    
  Scenario: check that claims can't be viewed even after challenge is revealed
  # TODO: Find a way to construct the link to a claim show page for someone who shouldn't be able to see it
  
  Scenario: check that completed ficlet is unrevealed
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When mod fulfills claim
  When I am logged in as "myname4"
  When I view the work "Fulfilled Story-thing"
  Then I should not see "In response to a prompt by myname4"
    And I should not see "Fandom: Stargate Atlantis"
    And I should not see "Anonymous"
    And I should not see "mod1"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Battle 12"
    
  Scenario: Mod can reveal challenge
  
  Given I have Battle 12 prompt meme fully set up
  When I close signups for "Battle 12"
  When I go to "Battle 12" collection's page
    And I follow "Collection Settings"
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
    
  Scenario: When a prompt is filled with a co-authored work, the e-mail should link to each author's URL instead of showing escaped HTML
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname1"
    And I sign up for Battle 12 with combination A
    And I log out
  When I am logged in as "myname2"
    And I claim a prompt from "Battle 12"
    And I start to fulfill my claim with "Co-authored Fill"
    And I add the co-author "myname3" 
  When I press "Post Without Preview"
  Then 1 email should be delivered to "myname3"
    And the email should contain "You have been listed as a coauthor on the following work"
  When I am logged in as "mod1"
    And I reveal the authors of the "Battle 12" challenge
    And I reveal the "Battle 12" challenge
  Then 1 email should be delivered to "myname1"
    And the email should link to myname2's user url
    And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/myname2/pseuds/myname2&quot;"
    And the email should link to myname3's user url
    And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/myname3/pseuds/myname3&quot;"
        
  Scenario: Story is anon when challenge is revealed
  
  Given I have standard challenge tags setup
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
  Then I should see "In response to a prompt by myname4"
    And I should see "Fandom: Stargate Atlantis"
    And I should see "Collections: Battle 12"
    And I should see "Anonymous" within ".byline"
    And I should not see "mod1" within ".byline"
    
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
  Then I should see "Fulfilled By"
    And I should see "Fulfilled Story by myname4" within "div.work"
    And I should see "Fulfilled Story-thing by mod1" within "div.work"


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
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "by Anonymous"
    And I should not see "by myname4"
  
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
  Then I should see "random SGA love by Anonymous"
  Then I should see "Fulfilled Story by myname2"
  Then I should see "High School AU SG1 by Anonymous "
  
  Scenario: Check that anon prompts are still anon on user claims index after challenge is revealed
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname2"
  When I am on my user page
    And I follow "Claims"
    # note that user Claims page currently only shows unfulfilled claims
  Then I should not see "myname4"
    And I should see "Anonymous"
    
  Scenario: Check that anon prompts are still anon on claims show after challenge is revealed
  # note that only mod can see claims show now - users don't get linked to it
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname4"
  When I sign up for Battle 12 with combination B
  When I close signups for "Battle 12"
  When I am logged in as "myname2"
  When I claim a prompt from "Battle 12"
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "mod1"
  When I am on "Battle 12" collection's page
    And I follow "Unposted Claims"
    And I follow "Anonymous"
  Then I should not see "myname4"
    And I should see "Anonymous"
    
  Scenario: check that anon prompts are still anon on the fulfilling work
  # TODO
  
  Scenario: Fulfilled claims show as fulfilled to another user
  
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
    And I go to the "Battle 12" requests page
  Then I should see "mod1" within ".prompt .work"
    And I should see "myname4" within ".prompt .work"
    
  Scenario: Make another claim and then fulfill from the post new form (New Work)
  
  Given I have Battle 12 prompt meme fully set up
  Given everyone has signed up for Battle 12
  When I close signups for "Battle 12"
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
  When I follow "New Work"
  When I fill in the basic work information for "Existing work"
    And I check "Battle 12 (myname4)"
    And I press "Preview"
  Then I should see "Draft was successfully created"
    And I should see "In response to a prompt by myname4"
    And 0 emails should be delivered
    When "AO3-3455" is fixed
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I view the work "Existing work"
  Then I should see "draft"
  
  Scenario: work left in draft so claim is not yet totally fulfilled
  
  Given I have Battle 12 prompt meme fully set up
  Given an anon has signed up for Battle 12
  When I close signups for "Battle 12"
  When I reveal the "Battle 12" challenge
  Given all emails have been delivered
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname4"
  When I claim a prompt from "Battle 12"
  When I start to fulfill my claim
    And I press "Preview"
  When I go to the "Battle 12" requests page
  Then I should see "Claimed By"
    And I should not see "Fulfilled By"
  When I am logged in as "mod1"
    And I go to "Battle 12" collection's page
    And I follow "Unposted Claims"
  Then I should see "myname4"
  When I am logged in as "myname4"
    And I go to my claims page
    # Draft not shown. Instead we see that there is a 'Fulfill' button which
    # we can use. Then use the 'Restore From Last Unposted Draft?' button
  When I follow "Fulfill"
    And I follow "Restore From Last Unposted Draft?"
  When I press "Post Without Preview"
    And I should see "Work was successfully posted."
  Then I should see "Fulfilled Story"
    
  Scenario: When draft is posted, claim is fulfilled and posted to collection
  
  Given I have Battle 12 prompt meme fully set up
  When I am logged in as "myname2"
    And I sign up for Battle 12 with combination B
  When I am logged in as "myname4"
    And I claim a prompt from "Battle 12"
  When I close signups for "Battle 12"
  When I reveal the "Battle 12" challenge
  When I reveal the authors of the "Battle 12" challenge
  When I am logged in as "myname4"
    And I go to the "Battle 12" requests page
  When I press "Claim"
  When I follow "Fulfill"
    And I fill in the basic work information for "Existing work"
    And I check "random SGA love in Battle 12 (Anonymous)"
    And I press "Preview"
  When I am on my user page
    And I follow "Drafts"
    And all emails have been delivered
  When I follow "Post Draft"
  Then 1 email should be delivered
  Then I should see "Your work was successfully posted"
    And I should see "In response to a prompt by Anonymous"
  When I go to "Battle 12" collection's page
    And I follow "Prompts ("
  Then I should see "myname4"
    And I should see "Fulfilled By"
  When I follow "Existing work"
  Then I should see "Existing work"
    And I should see "Battle 12"
    And I should not see "draft"
  
  Scenario: Fulfill a claim by editing an existing work
  
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
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
  Then I should see "In response to a prompt by"
    When "AO3-3455" is fixed
  #  And I should see "Collections:"
   # And I should see "Battle 12"
  When I press "Update"
  Then I should see "Work was successfully updated"
    And I should not see "draft"
    And I should see "In response to a prompt by"
  Then I should see "Collections:"
    And I should see "Battle 12"
    
  # claim is fulfilled on collection page
  When I go to "Battle 12" collection's page
    And I follow "Prompts"
  Then I should see "myname1" within ".prompt .work"
    And I should see "Fulfilled By"

  Scenario: Download prompt CSV from signups page
  
  Given I am logged in as "mod1"
    And I have standard challenge tags setup
    And I create Battle 12 promptmeme
  When I go to the "Battle 12" signups page
    And I follow "Download (CSV)"
  Then I should get a file with ending and type csv

  Scenario: Can't download prompt CSV from requests page
  # it's aimed at users, not mods
  
  Given I have Battle 12 prompt meme fully set up
    And everyone has signed up for Battle 12
    And I am logged in as "mod1"
  When I go to the "Battle 12" requests page
  Then I should not see "Download (CSV)"


  Scenario: Validation error doesn't cause semi-anon ticky to lose state (Issue 2617)
  Given I set up an anon promptmeme "Scotts Prompt" with name "scotts_prompt"
    And I am logged in as "Scott" with password "password"
    And I go to "Scotts Prompt" collection's page
    And I follow "Prompt Form"
    And I check "Semi-anonymous Prompt"
    And I press "Submit"
  Then I should see "There were some problems with this submission. Please correct the mistakes below."
    And I should see "Your Request must include between 1 and 2 fandom tags, but you have included 0 fandom tags in your current Request."
    And the "Semi-anonymous prompt" checkbox should be checked

  Scenario: Dates should be correctly set on PromptMemes
    Given I am logged in as "mod1"
      And I have standard challenge tags set up
      And I have no prompts
    When I set up Battle 12 promptmeme collection
      And I check "Sign-up open?"
      And I fill in "Sign-up opens:" with "2010-09-20 12:40AM"
      And I fill in "Sign-up closes:" with "2010-09-22 12:40AM"
      And I submit
      And I should see "If sign-ups are open, sign-up close date cannot be in the past."
    Then I fill in "Sign-up opens:" with "2022-09-20 12:40AM"
      And I fill in "Sign-up closes:" with "2010-09-22 12:40AM"
      And I submit
      And I should see "If sign-ups are open, sign-up open date cannot be in the future."
    Then I fill in "Sign-up opens:" with "2010-09-22 12:40AM"
      And I fill in "Sign-up closes:" with "2010-09-20 12:40AM"
      And I submit
      And I should see "Close date cannot be before open date."
