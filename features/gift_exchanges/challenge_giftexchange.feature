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
  Then My Gift Exchange gift exchange should be correctly created

  Scenario: Enter settings for a gift exchange
  Given I am logged in as "mod1"
    And I have set up the gift exchange "My Gift Exchange"
  When I fill in gift exchange challenge options
    And I submit
  Then My Gift Exchange gift exchange should be fully created

  Scenario: Open signup in a gift exchange
  Given I am logged in as "mod1"
    And I have created the gift exchange "My Gift Exchange"
    And I am on "My Gift Exchange" gift exchange edit page
  When I check "Sign-up open?"
    And I submit
  Then I should see "Challenge was successfully updated"
    And I should see "Sign-up: Open" within ".collection .meta"
    And I should see "Sign-up closes:"

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
  When I select "(GMT-09:00) Alaska" from "gift_exchange_time_zone"
    And I submit
  Then I should see "Challenge was successfully updated"
  Then I should find "Alaska"

  Scenario: Add a co-mod

  Given the following activated users exist
    | login   |
    | comod   |
    And I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
  When I go to "Awesome Gift Exchange" collection's page
    And I follow "Membership"
    And I fill in "participants_to_invite" with "comod"
    And I press "Submit"
  Then I should see "New members invited: comod"

  Scenario: Sign up for a gift exchange

  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
  When I am logged in as "myname1"
  When I sign up for "Awesome Gift Exchange" with combination A
  Then I should see "Sign-up was successfully created"
  
  
  Scenario: Optional tags should be saved when editing a signup (gcode issue #2729)
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I edit settings for "Awesome Gift Exchange" challenge
    And I check "Optional Tags?"
    And I submit
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
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
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
  When I am logged in as "myname1"
  When I sign up for "Awesome Gift Exchange" with combination A
  When I am on my user page
  Then I should see "Sign-ups (1)"
  When I follow "Sign-ups (1)"
  Then I should see "Awesome Gift Exchange"

  Scenario: Ordinary users cannot see other signups
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
  When I am logged in as "myname1"
  When I sign up for "Awesome Gift Exchange" with combination A
  When I go to the collections page
    And I follow "Awesome Gift Exchange"
  Then I should not see "Sign-ups" within "#dashboard"
  
  Scenario: Mod can view signups

  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
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

  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
    And everyone has signed up for the gift exchange "Awesome Gift Exchange"
  When I am logged in as "mod1"
    And I go to "Awesome Gift Exchange" collection's page
    And I follow "Matching"
  Then I should see "You can't generate matches while sign-up is still open."
    And I should not see "Generate Potential Matches"

  Scenario: Matches can be generated
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
    And everyone has signed up for the gift exchange "Awesome Gift Exchange"
  When I close signups for "Awesome Gift Exchange"
  When I follow "Matching"
  When I follow "Generate Potential Matches"
  Then I should see "Beginning generation of potential matches. This may take some time, especially if your challenge is large."
  Given the system processes jobs
    And I wait 3 seconds
  When I reload the page
  Then I should see "Main Assignments"

  Scenario: Assignments can be sent

  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
    And everyone has signed up for the gift exchange "Awesome Gift Exchange"
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
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
    And everyone has signed up for the gift exchange "Awesome Gift Exchange"
    And I have generated matches for "Awesome Gift Exchange"
    And I have sent assignments for "Awesome Gift Exchange"
  Given I have created the gift exchange "Second Challenge" with name "testcoll2"
    And I have opened signup for the gift exchange "Second Challenge"
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
    And I have opened signup for the gift exchange "Sensitive Gift Exchange"
  When I am logged in as "myname1"
  When I start to sign up for "Sensitive Gift Exchange" gift exchange
  Then I should see "othername"

  Scenario: User tries to change pseud on a challenge signup and should not be able to, as it would break matching

  Given "myname1" has the pseud "othername"
  Given I am logged in as "mod1"
    And I have created the gift exchange "Sensitive Gift Exchange"
    And I have opened signup for the gift exchange "Sensitive Gift Exchange"
  When I am logged in as "myname1"
  When I sign up for "Sensitive Gift Exchange" with combination A
  Then I should see "Sign-up was successfully created"
    And I should see "Sign-up for myname1"
  When I edit my signup for "Sensitive Gift Exchange"
  Then I should not see "othername"

  Scenario: User can see their assignment

  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
    And everyone has signed up for the gift exchange "Awesome Gift Exchange"
    And I have generated matches for "Awesome Gift Exchange"
    And I have sent assignments for "Awesome Gift Exchange"
  When I am logged in as "myname1"
    And I go to my user page
    And I follow "Assignments"
  Then I should see "Awesome Gift Exchange"

  Scenario: User fulfills their assignment and it shows on their assigments page as fulfilled
  
  Given I am logged in as "mod1"
    And I have created the gift exchange "Awesome Gift Exchange"
    And I have opened signup for the gift exchange "Awesome Gift Exchange"
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

  Scenario: Tagsets show up in Challenge metadata
  Given I am logged in as "mod1"
    And I have created the gift exchange "Cabbot Cove Remixes"
    And I go to the tagsets page
    And I follow the add new tagset link
    And I fill in "Title" with "Angela Lansbury"
    And I submit
    And I go to "Cabbot Cove Remixes" collection's page
    And I follow "Profile"
    And I should see "Tag set:"
    And I should see "Standard Challenge Tags"
  When I edit settings for "Cabbot Cove Remixes" challenge
    And I fill in "Tag Sets To Use:" with "Angela Lansbury"
    And I press "Update"
  Then I should see "Tag sets:"
    And I should see "Standard Challenge Tags"
    And I should see "Angela Lansbury"
  When I edit settings for "Cabbot Cove Remixes" challenge
    And I check "Standard Challenge Tags"
    And I check "Angela Lansbury"
    And I press "Update"
  Then I should not see "Tag sets:"
    And I should not see "Tag set:"
    And I should not see "Standard Challenge Tags"
    And I should not see "Angela Lansbury"




    

