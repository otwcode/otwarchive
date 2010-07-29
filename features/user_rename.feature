@wip @users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my username
  
Scenario: Renaming to change the capitalisation
  Given the following activated users exist
    | login       | password |
    | downthemall | password |
    | otheruser   | secret   |
    And I am logged in as "downthemall" with password "password"
  When I go to downthemall's user page
    And I follow "My Preferences"
    And I follow "Change My Username"
    And I fill in "Desired Username" with "otheruser"
    And I fill in "Password" with "password"
    And I press "Change"
  Then I should find "username already taken"
  When I fill in "Desired Username" with "DownThemAll"
    And I fill in "Password" with "password"
    And I press "Change"
  Then I should see "Your profile has been successfully updated."
    And I should see "Hi, DownThemAll"
  When I follow "Set My Preferences"
    And I follow "Change My Username"
    And I fill "Desired Username" with "Down-Thém-All"
    And I fill in "Password" with "password"
    And I press "Change"
  Then I should see "Your profile has been successfully updated."
    And I should see "Hi, Down-Thém-All"
  
  # TO DO: putting in the wrong password should show a good and error clear message
  # we need to decide what that message should be, however, so I can't even devise a proper failing test for it ;)