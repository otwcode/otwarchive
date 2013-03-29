@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my user name

Scenario: Changing my user name
  Given I have no users
    And the following activated user exists
    | login       | password |
    | otheruser   | secret   |
    And I am logged in as "downthemall" with password "password"
  When I go to downthemall's user page
    And I follow "Preferences"
    And I follow "Change My User Name"
    And I fill in "New User Name" with "otheruser"
    And I fill in "Re-enter Your Password" with "password"
  When I press "Change"
    Then I should see "User name already taken."
  When I fill in "New User Name" with "OtherUser"
    And I fill in "Re-enter Your Password" with "password"
    And I press "Change"
    Then I should see "User name already taken."
  When I fill in "New User Name" with "DownThemAll"
    And I fill in "Re-enter Your Password" with "password"
    And I press "Change"
  Then I should see "Your user name was changed"
    And I should see "Hi, DownThemAll"
  When I follow "Preferences"
    And I follow "Change My User Name"
    And I fill in "New User Name" with "Down_Them_All"
    And I fill in "Re-enter Your Password" with "wrongpwd"
    And I press "Change"
  Then I should see "Your password was incorrect"
  # specifications say that the Change button should be inactive until password is correct
  # and the error message should be clearer
  When I fill in "Re-enter Your Password" with "password"
    And I press "Change"
  Then I should see "Your user name was changed"
    And I should see "Hi, Down_Them_All"

Scenario: Changing my user name with one pseud changes that pseud
  Given I have no users
    And I am logged in as "oldusername" with password "password"
  When I go to oldusername's user page
    And I follow "Preferences"
    And I follow "Change My User Name"
    And I fill in "New User Name" with "newusername"
    And I fill in "Re-enter Your Password" with "password"
    And I press "Change"
  Then I should see "Your user name was changed"
    And I should see "Hi, newusername"
  When I go to my pseuds page
    Then I should not see "oldusername"
  When I follow "Edit"
  Then I should see "cannot change your fallback pseud"
  Then the "pseud_is_default" checkbox should be checked
    And the "pseud_is_default" checkbox should be disabled

Scenario: Changing my user name with two pseuds, one same as new, doesn't change old
  Given I have no users
    And the following activated user exists
    | login         | password | id |
    | oldusername   | secret   | 1  |
    And a pseud exists with name: "newusername", user_id: 1
    And I am logged in as "oldusername" with password "secret"
  When I go to oldusername's user page
    And I follow "Preferences"
    And I follow "Change My User Name"
    And I fill in "New User Name" with "newusername"
    And I fill in "Re-enter Your Password" with "secret"
    And I press "Change"
  Then I should see "Your user name was changed"
    And I should see "Hi, newusername"
  When I follow "Pseuds (2)"
    Then I should see "Edit oldusername"
    And I should see "Edit newusername"
