@users
Feature: General notice banner

  Scenario: Custom notice banner
  
  # banner is blank until admin sets it
  
  Given the following activated user exists
    | login         | password   |
    | newname       | password   |
  When I am on the home page
  Then I should not see "Hide this banner"
  When I am logged in as "newname" with password "password"
  Then I should not see "Hide this banner"
  When I am logged out
  
  # admin creates custom notice
  
  Given the following admin exists
      | login       | password |
      | Zooey       | secret   |
      
  When I go to the admin_login page
      And I fill in "admin_session_login" with "Zooey"
      And I fill in "admin_session_password" with "secret"
      And I press "Log in as admin"
    Then I should see "Successfully logged in"
  
  When I follow "settings"
  Then I should see "Banner notice"
  When I fill in "Banner notice" with "Custom notice words"
    And I press "Update"
  Then I should see "Archive settings were successfully updated."
  When I follow "Log out"
  
  # user views banner and then turns it off

  When I am logged in as "newname" with password "password"
  Then I should see "Hi, newname!"
    And I should see "Log out"
  When I am on newname's user page
  Then I should see "Custom notice words"
  When I follow "Hide this banner"
  Then I should not see "Custom notice words"
  When I am logged out
    And I am logged in as "newname" with password "password"
  Then I should not see "Custom notice words"
  When I am on newname's user page
  Then I should not see "Custom notice words"
  
  # logged out user can also see banner
  
  When I am logged out
  Then I should see "Custom notice words"
  
  # TODO: logged out user hides banner
