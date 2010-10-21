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
    And I follow "My Preferences"
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
  When I follow "My Preferences"
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
