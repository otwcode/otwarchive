@users
Feature: General notice banner

Scenario: Banner is blank until admin sets it

  When I am on the home page
  Then I should not see "Hide this banner"
  When I am logged in as "newname"
  Then I should not see "Hide this banner"

Scenario: Admin can change banner

  When an admin sets a custom banner notice
    And I am logged in as "ordinaryuser"
  Then the banner notice should be set to "Custom notice"

  Scenario: Custom notice banner
  
  When an admin sets a custom banner notice
  
  # user views banner and then turns it off

  When I am logged in as "newname"
  When I am on my user page
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
