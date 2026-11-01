@collections @challenges
Feature: Gift Exchange Challenge
  In order to have an archive full of works
  As a humble user
  I want individual requests and signups on a gift exchange to be appropriately visible

  # All of these tests are for AO3-5890.

  Scenario: The "All Requests in Sign-up" link leads to an individual sign-up page
    Given the gift exchange "My Gift Exchange" is ready for matching
      And I set "My Gift Exchange" requests to visible
    When I am logged in as a random user
      And I am on the "My Gift Exchange" requests page
      And I follow "All Requests in Sign-up"
    Then I should be on the "My Gift Exchange" signup page for the user "myname4"

  Scenario Outline: Sign-up pages (both requests and offers) should be visible to owner and mod
    Given the gift exchange "My Gift Exchange" is ready for matching
      And I set "My Gift Exchange" requests to visible
    When I am logged in as "<username>"
      And I go to the "My Gift Exchange" signup page for the user "myname2"
    Then I should see "Sign-up for myname2"
      And I should see "Request 1"
      And I should see "Stargate SG-1"
      And I should see "Offer 1"
      And I should see "Stargate Atlantis"

    Examples:
    | username |
    | myname2  |
    | mod1     |

  Scenario: Sign-up pages (only requests) should be visible to others
    Given the gift exchange "My Gift Exchange" is ready for matching
      And I set "My Gift Exchange" requests to visible
    When I am logged in as "myname3"
      And I go to the "My Gift Exchange" signup page for the user "myname2"
    Then I should see "Sign-up for myname2"
      And I should see "Request 1"
      And I should see "Stargate SG-1"
      But I should not see "Offer 1"
      And I should not see "Stargate Atlantis"

  Scenario Outline: Sign-up pages should still be visible for owner and mod when "requests visible" is off
    Given the gift exchange "My Gift Exchange" is ready for matching
    When I am logged in as "<username>"
      And I go to the "My Gift Exchange" signup page for the user "myname2"
    Then I should see "Sign-up for myname2"

    Examples:
    | username |
    | myname2  |
    | mod1     |

  Scenario: Sign-up pages should error out for others when "requests visible" is off
    Given the gift exchange "My Gift Exchange" is ready for matching
    When I am logged in as "myname3"
      And I go to the "My Gift Exchange" signup page for the user "myname2"
    Then I should see "You are not allowed to access that sign-up."
      And I should not see "Sign-up for myname2"

  Scenario: Individual requests should be visible to everyone
    Given the gift exchange "My Gift Exchange" is ready for matching
      And I set "My Gift Exchange" requests to visible
    When I am logged in as a random user
      And I go to the "My Gift Exchange" requests page
      And I follow "Request"
    Then I should see "Request by myname4"
      And I should see "Stargate Atlantis"
      And I should see "Alternate Universe - Historical"

  Scenario: Bylines on requests should link to prompter's dashboard
    Given the gift exchange "My Gift Exchange" is ready for matching
      And I set "My Gift Exchange" requests to visible
    When I am logged in as a random user
      And I go to the "My Gift Exchange" requests page
      And I follow "myname1_pseud (myname1)"
    Then I should be on the user page for user "myname1" with pseud "myname1_pseud"
