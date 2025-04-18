Feature: invitations
In order to join the archive
As an unregistered user
I want to use an invitation to create an account

  Scenario: user attempts to use an invitation

  Given account creation is enabled
    And account creation requires an invitation
    And I am a visitor
  When I use an invitation to sign up
  Then I should see "Create Account"

  Scenario: user attempts to use an already redeemed invitation

  Given account creation is enabled
    And account creation requires an invitation
    And I am a visitor
  When I use an already used invitation to sign up
  Then I should see "This invitation has already been used to create an account"

  Scenario: I visit the invitations page for a non-existent user

  Given I am a visitor
    And I go to SOME_USER's invitations page
  Then I should be on the login page
    And I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
    When I am logged in as "Scott" with password "password"
    And I go to SOME_USER2's invitations page
  Then I should be on Scott's user page
    And I should see "Sorry, you don't have permission to access the page you were trying to reach."

  Scenario: Viewing invitation details when the invitee has deleted their account
    Given the user "creator" exists and is activated
      And the user "invitee" exists and is activated
      And an invitation created by "creator" and used by "invitee"
      And I am logged in as "creator"
    When I go to creator's manage invitations page
    Then I should see "invitee"
    When I view the most recent invitation for "creator"
    Then I should see "invitee"
    When I am logged in as "invitee"
      And "invitee" deletes their account
      And I am logged in as "creator"
      And I go to creator's manage invitations page
    Then I should see "Deleted User"
      But I should not see "invitee"
    When I view the most recent invitation for "creator"
    Then I should see "Deleted User"
      But I should not see "invitee"
