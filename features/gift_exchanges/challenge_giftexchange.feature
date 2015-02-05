@collections
Feature: Gift Exchange Challenge
  In order to have more fics for my fandom
  As a humble user
  I want to run a gift exchange

  Scenario: Create a collection to house a gift exchange
    Given I am logged in as "mod1"
      And I have standard challenge tags setup
    When I set up the collection "My Gift Exchange"
      And I select "Gift Exchange" from "challenge_type"
      And I submit
    Then "My Gift Exchange" gift exchange should be correctly created

  Scenario: Enter settings for a gift exchange
    Given I am logged in as "mod1"
      And I have set up the gift exchange "My Gift Exchange"
    When I fill in gift exchange challenge options
      And I submit
    Then "My Gift Exchange" gift exchange should be fully created

  Scenario: Open signup in a gift exchange
    Given I am logged in as "mod1"
      And I have created the gift exchange "My Gift Exchange"
      And I am on "My Gift Exchange" gift exchange edit page
    When I check "Sign-up open?"
      And I submit
    Then I should see "Challenge was successfully updated"
      And I should see "Sign-up: Open" within ".collection .meta"
      And I should see "Sign-up Closes:"

  Scenario: Gift exchange appears in list of open challenges
    Given I am logged in as "mod1"
      And I have created the gift exchange "My Gift Exchange"
      And I am on "My Gift Exchange" gift exchange edit page
    When I check "Sign-up open?"
      And I submit
    When I view open challenges
    Then I should see "My Gift Exchange"

  Scenario: Gift exchange also appears in list of open gift exchange challenges
    Given I am logged in as "mod1"
      And I have created the gift exchange "My Gift Exchange"
      And I am on "My Gift Exchange" gift exchange edit page
    When I check "Sign-up open?"
      And I submit
    When I view open challenges
      And I follow "Gift Exchange Challenges"
    Then I should see "My Gift Exchange"

  Scenario: Change timezone for a gift exchange
    Given I am logged in as "mod1"
      And I have created the gift exchange "My Gift Exchange"
      And I am on "My Gift Exchange" gift exchange edit page
    When I select "(GMT+10:00) Port Moresby" from "gift_exchange_time_zone"
      And I submit
    Then I should see "Challenge was successfully updated"
    Then I should see "PGT"

  Scenario: Add a co-mod
    Given the following activated users exist
      | login   |
      | comod   |
      And I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
    When I go to "Awesome Gift Exchange" collection's page
      And I follow "Membership"
      And I fill in "participants_to_invite" with "comod"
      And I press "Submit"
    Then I should see "New members invited: comod"

  Scenario: Sign up for a gift exchange
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
      And I am logged in as "myname1"
    When I sign up for "Awesome Gift Exchange" with combination A
    Then I should see "Sign-up was successfully created"
    # Invalid signup should warn the user
    When I create an invalid signup in the gift exchange "Awesome Gift Exchange"
      And I reload the page
    Then I should see "sign-up is invalid"  

  Scenario: Optional tags should be saved when editing a signup (gcode issue #2729)
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
      And I edit settings for "Awesome Gift Exchange" challenge
      And I check "Optional Tags?"
      And I submit
    When I am logged in as "myname1"
      And I sign up for "Awesome Gift Exchange" with combination A
      And I follow "Edit Sign-up"
      And I fill in "Optional Tags:" with "My extra tag, Something else weird" 
      And I submit
    Then I should see "Something else weird"
    When I follow "Edit Sign-up"
      And I submit
    Then I should see "Something else weird"

  Scenario: Sign-ups can be seen in the dashboard
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
    When I am logged in as "myname1"
      And I sign up for "Awesome Gift Exchange" with combination A
    When I am on my user page
    Then I should see "Sign-ups (1)"
    When I follow "Sign-ups (1)"
    Then I should see "Awesome Gift Exchange"

  Scenario: Ordinary users cannot see other signups
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
      And I am logged in as "myname1"
    When I sign up for "Awesome Gift Exchange" with combination A
      And I go to the collections page
      And I follow "Awesome Gift Exchange"
    Then I should not see "Sign-ups" within "#dashboard"
  
  Scenario: Mod can view signups
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
    When I am logged in as "mod1"
      And I go to "Awesome Gift Exchange" collection's page
      And I follow "Sign-ups"
    Then I should see "myname4" within "#main"
      And I should see "myname3" within "#main"
      And I should see "myname2" within "#main"
      And I should see "myname1" within "#main"
      And I should see "Something else weird"
      And I should see "Alternate Universe - Historical"

  Scenario: Cannot generate matches while signup is open
    Given the gift exchange "Awesome Gift Exchange" is ready for signups
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
    When I am logged in as "mod1"
      And I go to "Awesome Gift Exchange" collection's page
      And I follow "Matching"
    Then I should see "You can't generate matches while sign-up is still open."
      And I should not see "Generate Potential Matches"

  Scenario: Matches can be generated
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I close signups for "Awesome Gift Exchange"
    When I follow "Matching"
      And I follow "Generate Potential Matches"
    Then I should see "Beginning generation of potential matches. This may take some time, especially if your challenge is large."
    Given the system processes jobs
      And I wait 3 seconds
    When I reload the page
    Then I should see "Reviewing Assignments"
      And I should see "Complete"

  Scenario: Invalid signups are caught before generation
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I create an invalid signup in the gift exchange "Awesome Gift Exchange"
    When I close signups for "Awesome Gift Exchange"
      And I follow "Matching"
      And I follow "Generate Potential Matches"
      And the system processes jobs
      And I wait 3 seconds
    Then 1 email should be delivered to "mod1"
      And the email should contain "invalid sign-up"
    When I go to "Awesome Gift Exchange" gift exchange matching page  
    Then I should see "Generate Potential Matches"
      And I should see "invalid sign-ups"

  Scenario: Assignments can be updated and cannot be sent out until everyone is assigned
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I have generated matches for "Awesome Gift Exchange"
    When I remove a recipient
      And I press "Save Assignment Changes"
    Then I should see "Assignments updated"
      And I should see "No Recipient"
      And I should see "No Giver"
    When I follow "Send Assignments"
    Then I should see "aren't assigned"
    When I follow "No Giver"
      And I assign a pinch hitter
      And I press "Save Assignment Changes"
    Then I should see "Assignments updated"
      And I should not see "No Giver"
    When I follow "No Recipient"
      And I assign a pinch recipient
      And I press "Save Assignment Changes"
      And I should not see "No Recipient"
    When I follow "Send Assignments"
    Then I should see "Assignments are now being sent out"

  Scenario: Issues with assignments
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I have generated matches for "Awesome Gift Exchange"
    When I assign a recipient to herself
      And I press "Save Assignment Changes"
    Then I should not see "Assignments updated"
      And I should see "do not match"  
    When I manually destroy the assignments for "Awesome Gift Exchange"
      And I go to "Awesome Gift Exchange" gift exchange matching page  
    Then I should see "Regenerate Assignments"
      And I should see "Regenerate All Potential Matches"
      And I should see "try regenerating assignments"
    When I follow "Regenerate Assignments"
      And the system processes jobs
      And I wait 3 seconds
      And I reload the page
    Then I should see "Reviewing Assignments"
      And I should see "Complete"

  Scenario: Matches can be regenerated for a single signup
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I am logged in as "Mismatch"
      And I sign up for "Awesome Gift Exchange" with a mismatched combination
    When I am logged in as "mod1"
      And I have generated matches for "Awesome Gift Exchange"
    Then I should see "No Potential Givers"
      And I should see "No Potential Recipients"
    When I follow "No Potential Givers"
      Then I should see "Regenerate Matches For Mismatch"
    When I follow "Edit"
      And I check the 1st checkbox with the value "Stargate Atlantis"
      And I uncheck the 1st checkbox with the value "Bad Choice"
      And I check the 2nd checkbox with the value "Stargate Atlantis"
      And I uncheck the 2nd checkbox with the value "Bad Choice"
      And I submit
      And I follow "Matching"
      And I follow "No Potential Recipients"
      And I follow "Regenerate Matches For Mismatch"
    Then I should see "Matches are being regenerated for Mismatch"
    When the system processes jobs
      And I wait 3 seconds
      And I reload the page
    Then I should not see "No Potential Givers"
      And I should not see "No Potential Recipients"
    When I follow "Regenerate Assignments"
      And the system processes jobs
      And I wait 3 seconds
      And I reload the page
    Then I should not see "No Potential Givers"
      And I should not see "No Potential Recipients"
      And I should see "Complete"

  Scenario: Assignments can be sent
    Given the gift exchange "Awesome Gift Exchange" is ready for matching
      And I have generated matches for "Awesome Gift Exchange"
    When I follow "Send Assignments"
    Then I should see "Assignments are now being sent out"
    Given the system processes jobs
      And I wait 3 seconds
    When I reload the page
    Then I should not see "Assignments are now being sent out"
    # 4 users and the mod should get emails :)
      And 1 email should be delivered to "mod1"
      And the email should contain "You have received a message about your collection"
      And 1 email should be delivered to "myname1"
      And 1 email should be delivered to "myname2"
      And 1 email should be delivered to "myname3"
      And 1 email should be delivered to "myname4"
      And the email should link to "Awesome Gift Exchange" collection's url
      And the email should link to myname1's user url
      And the email html body should link to the works tagged "Stargate Atlantis"

  Scenario: User signs up for two gift exchanges at once #'
    Given I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
      And I have generated matches for "Awesome Gift Exchange"
      And I have sent assignments for "Awesome Gift Exchange"
    Given I have created the gift exchange "Second Challenge" with name "testcoll2"
      And I open signups for "Second Challenge"
      And everyone has signed up for the gift exchange "Second Challenge"
      And I have generated matches for "Second Challenge"
      And I have sent assignments for "Second Challenge"
    When I am logged in as "myname1"
      And I start to fulfill my assignment
      # This is in fact a bug - only one of them should be checked
      # TODO: Uncomment when the intermittent bug has been fixed
    #Then the "Awesome Gift Exchange (myname3)" checkbox should be checked
    #  And the "Second Challenge (myname3)" checkbox should be checked

  Scenario: User has more than one pseud on signup form
    Given "myname1" has the pseud "othername"
    Given I am logged in as "mod1"
      And I have created the gift exchange "Sensitive Gift Exchange"
      And I open signups for "Sensitive Gift Exchange"
    When I am logged in as "myname1"
    When I start to sign up for "Sensitive Gift Exchange"
    Then I should see "othername"

  Scenario: User tries to change pseud on a challenge signup and should not be able to, as it would break matching
    Given "myname1" has the pseud "othername"
    Given I am logged in as "mod1"
      And I have created the gift exchange "Sensitive Gift Exchange"
      And I open signups for "Sensitive Gift Exchange"
    When I am logged in as "myname1"
    When I sign up for "Sensitive Gift Exchange" with combination A
    Then I should see "Sign-up was successfully created"
      And I should see "Sign-up for myname1"
    When I edit my signup for "Sensitive Gift Exchange"
    Then I should not see "othername"

  Scenario: Mod can see everyone's assignments, includind users' emails
    Given I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
      And I have generated matches for "Awesome Gift Exchange"
      And I have sent assignments for "Awesome Gift Exchange"
    When I go to the "Awesome Gift Exchange" assignments page
      Then I should see "Assignments for Awesome"
    When I follow "Open"
    Then I should see "Open Assignments"
      And I should see "myname1"
      And I should see the image "alt" text "email myname1"

  Scenario: User can see their assignment, but no email links
    Given I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
      And I have generated matches for "Awesome Gift Exchange"
      And I have sent assignments for "Awesome Gift Exchange"
    When I am logged in as "myname1"
      And I go to my user page
      And I follow "Assignments"
    Then I should see "Awesome Gift Exchange"
    When I follow "Awesome Gift Exchange"
      Then I should see "Requests by myname3"
      But I should not see the image "alt" text "email myname3"
      And I should see "Offers by myname1"
      But I should not see the image "alt" text "email myname1"

  Scenario: User fulfills their assignment and it shows on their assigments page as fulfilled

    Given I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
      And I have generated matches for "Awesome Gift Exchange"
      And I have sent assignments for "Awesome Gift Exchange"
    When I am logged in as "myname1"
      And I fulfill my assignment
    When I go to my user page
      And I follow "Assignments"
    Then I should see "Awesome Gift Exchange"
      And I should not see "Not yet posted"
      And I should see "Fulfilled Story"

  Scenario: Download signups CSV
    Given I am logged in as "mod1"
    And I have created the gift exchange "My Gift Exchange"

    When I go to the "My Gift Exchange" signups page
    And I follow "Download (CSV)"
    Then I should get a file with ending and type csv

  Scenario: View a signup summary with no tags
    Given the following activated users exist
    | login   | password |
    | user1   | password |
    | user2   | password |
    | user3   | password |
    | user4   | password |
    | user5   | password |
    | user6   | password |
    When I am logged in as "mod1"
      And I have created the tagless gift exchange "My Gift Exchange"
      And I open signups for "My Gift Exchange"
    When I am logged in as "user1" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "user2" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "user3" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "user4" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "user5" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "user6" with password "password"
      And I start to sign up for "My Gift Exchange" tagless gift exchange
    When I am logged in as "mod1"
      And I go to "My Gift Exchange" collection's page
      And I follow "Sign-up Summary"
    Then I should not see "Summary does not appear until at least"
      And I should see "Tags were not used in this Challenge, so there is no summary to display here."

  Scenario: Tagsets show up in Challenge metadata
    Given I am logged in as "mod1"
      And I have created the gift exchange "Cabbot Cove Remixes"
      And I go to the tagsets page
      And I follow the add new tagset link
      And I fill in "Title" with "Angela Lansbury"
      And I submit
      And I go to "Cabbot Cove Remixes" collection's page
      And I follow "Profile"
      And I should see "Tag Set:"
      And I should see "Standard Challenge Tags"
    When I edit settings for "Cabbot Cove Remixes" challenge
      And I fill in "Tag Sets To Use:" with "Angela Lansbury"
      And I press "Update"
    Then I should see "Tag Sets:"
      And I should see "Standard Challenge Tags"
      And I should see "Angela Lansbury"
    When I edit settings for "Cabbot Cove Remixes" challenge
      And I check "Standard Challenge Tags"
      And I check "Angela Lansbury"
      And I press "Update"
    Then I should not see "Tag Sets:"
      And I should not see "Tag Set:"
      And I should not see "Standard Challenge Tags"
      And I should not see "Angela Lansbury"

  Scenario: Mod deletes a user's sign-up and a user deletes their own sign-up without JavaScript
    Given I am logged in as "mod1"
      And I have created the gift exchange "Awesome Gift Exchange"
      And I open signups for "Awesome Gift Exchange"
      And everyone has signed up for the gift exchange "Awesome Gift Exchange"
    When I am logged in as "mod1"
      And I go to the "Awesome Gift Exchange" signups page
      And I delete the signup by "myname1"
    Then I should see "Challenge sign-up was deleted." 
    When I am logged in as "myname2"
      And I delete my signup for the gift exchange "Awesome Gift Exchange"
    Then I should see "Challenge sign-up was deleted."
