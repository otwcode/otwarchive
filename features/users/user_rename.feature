@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my user name

  Scenario: The user should not be able to change username without a password
    Given I am logged in as "testuser" with password "password"
    When I visit the change username page for testuser
      And I press "Change User Name"
    # TODO - better written error message
    Then I should see "Your password was incorrect"

  Scenario: The user should not be able to change their username with an incorrect password
    Given I am logged in as "testuser" with password "password"
    When I visit the change username page for testuser
      And I fill in "New User Name" with "anothertestuser"
      And I fill in "Password" with "wrongpwd"
      And I press "Change User Name"
    Then I should see "Your password was incorrect"

  Scenario: The user should not be able to change their username to another user's name
    Given I have no users
      And the following activated user exists
      | login     | password |
      | otheruser | secret   |
      And I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New User Name" with "otheruser"
      And I fill in "Password" with "password"
    When I press "Change"
      Then I should see "User name already taken."

  Scenario: The user should not be able to change their username to another user's name even if the capitalization is different
    Given I have no users
      And the following activated user exists
      | login     | password |
      | otheruser | secret   |
      And I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New User Name" with "OtherUser"
      And I fill in "Password" with "password"
      And I press "Change User Name"
    Then I should see "User name already taken."

  Scenario: The user should be able to change their username if username and password are valid
    Given I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New User Name" with "DownThemAll"
      And I fill in "Password" with "password"
      And I press "Change"
    Then I should get confirmation that I changed my username
      And I should see "Hi, DownThemAll!"

  Scenario: The user should be able to change their username to a similar version with underscores
    Given I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New User Name" with "Down_Them_All"
      And I fill in "Password" with "password"
      And I press "Change User Name"
    Then I should get confirmation that I changed my username
      And I should see "Hi, Down_Them_All!"

  Scenario: Changing my user name with one pseud changes that pseud
    Given I have no users
      And I am logged in as "oldusername" with password "password"
    When I visit the change username page for oldusername
      And I fill in "New User Name" with "newusername"
      And I fill in "Password" with "password"
      And I press "Change User Name"
    Then I should get confirmation that I changed my username
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
    When I visit the change username page for oldusername
      And I fill in "New User Name" with "newusername"
      And I fill in "Password" with "secret"
      And I press "Change User Name"
    Then I should get confirmation that I changed my username
      And I should see "Hi, newusername"
    When I follow "Pseuds (2)"
      Then I should see "Edit oldusername"
      And I should see "Edit newusername"
