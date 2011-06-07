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
  Then the banner notice for a logged-in user should be set to "Custom notice"

Scenario: User can turn off banner, and it stays off when logging out and in again
  
  When an admin sets a custom banner notice
  When I am logged in as "newname"
  When I am on my user page
  When I follow "Hide this banner"
  Then I should not see "Custom notice words"
  When I am logged out
    And I am logged in as "newname" with password "password"
  Then I should not see "Custom notice words"
  When I am on newname's user page
  Then I should not see "Custom notice words"
  
Scenario: logged out user can also see banner
  
  When an admin sets a custom banner notice
  Then the banner notice for a logged-out user should be set to "Custom notice"
  
Scenario: logged out user hides banner

  When an admin sets a custom banner notice
  When I am logged out
  When I am on the works page
  When I follow "Hide this banner"
  Then I should not see "Custom notice words"
