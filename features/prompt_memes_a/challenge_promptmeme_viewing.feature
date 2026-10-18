@collections @challenges @promptmemes
Feature: Prompt Meme Challenge
  In order to have an archive full of works
  As a humble user
  I want individual requests and signups on a prompt meme to be appropriately visible

  # All of these tests are for AO3-5890.

  # Combination A:  0 anon, 2 non-anon prompts
  # No combination: 1 anon, 1 non-anon prompts
  # Combination B:  2 anon, 0 non-anon prompts

  Scenario: The "All Requests in Sign-up" link leads to an individual sign-up page
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12 with combination A
    When I am logged in as a random user
      And I view prompts for "Battle 12"
      And I follow "All Requests in Sign-up"
    Then I should be on the "Battle 12" signup page for the user "myname1"

  Scenario Outline: The "All Requests in Sign-up" link is still visible for anon prompts if owner or mod
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12 with combination B
    When I am logged in as "<username>"
      And I view prompts for "Battle 12"
    Then I should see "All Requests in Sign-up"

    Examples:
    | username |
    | myname1  |
    | mod1     |

  Scenario: The "All Requests in Sign-up" link does not appear on anon prompts for others
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12 with combination B
    When I am logged in as "myname2"
      And I view prompts for "Battle 12"
    Then I should not see "All Requests in Sign-up"

  Scenario Outline: Sign-up pages (both their anon and non-anon prompts) should be visible to owner and mod
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12
    When I am logged in as "<username>"
      And I go to the "Battle 12" signup page for the user "myname1"
    Then I should see "crack by myname1"
      And I should see "Request 2 by Anonymous"
  
    Examples:
    | username |
    | myname1  |
    | mod1     |

  Scenario: Sign-up pages (only their non-anon prompts) should be visible to others
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12
    When I am logged in as "myname2"
      And I go to the "Battle 12" signup page for the user "myname1"
    Then I should see "crack by myname1"
      But I should not see "Request 2 by Anonymous"

  Scenario Outline: Sign-up pages with only anon prompts should still be visible to owner and mod
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12 with combination B
    When I am logged in as "<username>"
      And I go to the "Battle 12" signup page for the user "myname1"
    Then I should see "High School AU SG1 by Anonymous"
      And I should see "random SGA love by Anonymous"

    Examples:
    | username |
    | myname1  |
    | mod1     |

  Scenario: Sign-up pages with only anon prompts should error out for others
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12 with combination B
    When I am logged in as "myname2"
      And I go to the "Battle 12" signup page for the user "myname1"
    Then I should see "You are not allowed to access that sign-up."
      And I should not see "High School AU SG1 by Anonymous"
      And I should not see "random SGA love by Anonymous"

  Scenario: Individual prompts should be visible to everyone
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12
    When I am logged in as a random user
      And I view prompts for "Battle 12"
      And I follow "crack"
    Then I should see "crack by myname1"
      And I should see "Stargate SG-1"
      And I should see "Something else weird"
    When I view prompts for "Battle 12"
      And I follow "Request"
    Then I should see "Request by Anonymous"
      And I should see "Stargate SG-1"

  Scenario: Bylines on non-anon prompts should link to prompter's dashboard
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12
    When I am logged in as a random user
      And I view prompts for "Battle 12"
      And I follow "myname1"
    Then I should be on the user page for user "myname1" with pseud "myname1"

  Scenario: Bylines on anon prompts should not have a link
    Given I have Battle 12 prompt meme fully set up
      And I am logged in as "myname1"
      And I sign up for Battle 12
    When I am logged in as a random user
      And I view prompts for "Battle 12"
    Then I should not see a link "Anonymous"