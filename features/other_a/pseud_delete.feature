@users
Feature: Delete pseud.
  In order to tidy some mess
  As a humble user
  I want to delete a pseud

  Scenario: Delete pseud, have option to move works, delete works, or orphan works. Test if those choices work.
  Given I have loaded the fixtures
  When I am logged in as "sad_user_with_no_pseuds" with password "testuser"
    And I am on sad_user_with_no_pseuds's pseuds page
  Then I should not see "Delete"
  When I am logged out
  And I am logged in as "testuser" with password "testuser"
    And I am on testuser's pseuds page
  When I follow "delete_tester_pseud"
  Then I should see "Delete these bookmarks"
  When I choose "Delete these bookmarks"
    And I press "Submit"
  Then I should see "The pseud was successfully deleted."
  When I am on testuser's pseuds page
    Then I should not see "tester_pseud"
    And I follow "delete_testy"
    And I choose "Transfer these bookmarks to the default pseud"
    And I press "Submit"
  Then I should see "The pseud was successfully deleted."
  When I am on testuser's pseuds page
    And I follow "testymctesty"
  Then I should see "fourth"
    And I should not see "fifth work"

  Scenario: Deleting a pseud shouldn't break gift exchange signups.

    Given I am logged in as "moderator"
      And I set up the collection "Exchange1"
      And I select "Gift Exchange" from "challenge_type"
      And I press "Submit"
      And I check "Sign-up open?"
      And I press "Submit"
      And I am logged in as "test"
      And I add the pseud "testpseud"

    When I start signing up for "Exchange1"
      And I select "testpseud" from "challenge_signup_pseud_id"
      And I fill in "Description:" with "Antidisestablishmentarianism."
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I view the collection "Exchange1"
      And I follow "My Sign-up"
    Then I should see "Antidisestablishmentarianism."

    When I am on test's pseuds page
      And I follow "Delete"
    Then I should see "The pseud was successfully deleted."

    When I view the collection "Exchange1"
      And I follow "My Sign-up"
    Then I should see "Antidisestablishmentarianism."

  Scenario: Deleting a pseud shouldn't break prompt meme signups.

    Given I am logged in as "moderator"
      And I set up the collection "PromptsGalore"
      And I select "Prompt Meme" from "challenge_type"
      And I press "Submit"
      And I press "Submit"
      And I am logged in as "test"
      And I add the pseud "testpseud"

    When I start signing up for "PromptsGalore"
      And I select "testpseud" from "challenge_signup_pseud_id"
      And I fill in "Description:" with "Antidisestablishmentarianism."
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I view the collection "PromptsGalore"
      And I follow "My Prompts"
    Then I should see "Antidisestablishmentarianism."

    When I am on test's pseuds page
      And I follow "Delete"
    Then I should see "The pseud was successfully deleted."

    When I view the collection "PromptsGalore"
      And I follow "My Prompts"
    Then I should see "Antidisestablishmentarianism."

