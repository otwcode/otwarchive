@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my username
  
Scenario: Changing my username
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
  Then I should find "username already taken"
  # I can't figure out how to test this in cucumber,
  # but when you're in a browser with JS it doesn't let you go further if validation of username fails
  # When I press "Change"
  # Then I should not see "We couldn't save this user, sorry!"
  When issue "about capitalisation changes" is fixed
  # When I fill in "Desired Username" with "DownThemAll"
    # And I fill in "Password" with "password"
    # And I press "Change"
  # Then I should see "Your profile has been successfully updated."
    # And I should see "Hi, DownThemAll"
  When I follow "My Preferences"
    And I follow "Change My Username"
    And I fill in "Desired Username" with "Down_Them_All"
    And I fill in "Password" with "wrongpwd"
    And I press "Change"
  Then I should see "Your update failed; please try again."
  # specifications say that the Change button should be inactive until password is correct
  # and the error message should be clearer
  When I follow "Change My Username"
    And I fill in "Desired Username" with "Down_Them_All"
    And I fill in "Password" with "password"
    And I press "Change"
  Then I should see "Your profile has been successfully updated."
    And I should see "Hi, Down_Them_All"
