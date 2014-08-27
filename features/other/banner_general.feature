@users
Feature: General notice banner

Scenario: Banner is blank until admin sets it

  When I am on the home page
  Then I should not see "×"
  When I am logged in as "newname"
  Then I should not see "×"

Scenario: Admin can set a banner
  Given an admin creates an active banner
  Then a logged-in user should see the banner
    And a logged-out user should see the banner

Scenario: Admin can set an alert banner
  Given an admin creates an active "alert" banner
  Then a logged-in user should see the "alert" banner
    And a logged-out user should see the "alert" banner

Scenario: Admin can set an event banner
  Given an admin creates an active "event" banner
  Then a logged-in user should see the "event" banner
    And a logged-out user should see the "event" banner

Scenario: Admin can turn off a banner
  Given an admin creates an active banner
  #Then a logged-in user should see the banner
    #And a logged-out user should see the banner
  When an admin deactivates the banner
  Then a logged-in user should not see a banner
    And a logged-out user should not see a banner

Scenario: User can turn off banner using "×" button
  Given an admin creates an active banner
  When I turn off the banner
  Then I should not see "This is some banner text"

Scenario: Banner stays off when logging out and in again
  Given an admin creates an active banner
    And I turn off the banner
  When I am logged out
    And I am logged in as "newname"
  Then I should not see "This is some banner text"
  
Scenario: Logged out user can turn off banner
  Given an admin creates an active banner
    And I am logged out
  When I follow "×"
  Then I should not see "This is some banner text"
   
Scenario: User can turn off banner in preferences
  Given an admin creates an active banner
    And I am logged in as "newname"
  When I set my preferences to turn off the banner showing on every page
  Then I should not see "This is some banner text"

Scenario: User can turn off banner in preferences, but will still see a banner when an admin sets a new banner
  Given an admin creates an active banner
    And I am logged in as "newname"
  When I set my preferences to turn off the banner showing on every page
  Then I should not see "This is some banner text"
  When an admin creates a different active banner
    And I am logged in as "newname"
  Then I should see "This is new banner text"
