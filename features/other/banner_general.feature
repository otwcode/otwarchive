@users
Feature: General notice banner

Scenario: Banner is blank until admin sets it
  Given there are no banners
  Then a logged-in user should not see a banner
    And a logged-out user should not see a banner

Scenario: Admin can set a banner
  Given there are no banners
    And an admin creates an active banner
  Then a logged-in user should see the banner
    And a logged-out user should see the banner

Scenario: Admin can set an alert banner
  Given there are no banners
    And an admin creates an active "alert" banner
  When I am logged in as "whatever"
  Then a logged-in user should see the "alert" banner
    And a logged-out user should see the "alert" banner

Scenario: Admin can set an event banner
  Given there are no banners
    And an admin creates an active "event" banner
  Then a logged-in user should see the "event" banner
    And a logged-out user should see the "event" banner

Scenario: Admin can edit an active banner
  Given there are no banners
    And an admin creates an active banner
  When an admin edits the active banner
  Then a logged-in user should see the edited active banner
    And a logged-out user should see the edited active banner

Scenario: Admin can deactivate a banner
  Given there are no banners
    And an admin creates an active banner
  When an admin deactivates the banner
  Then a logged-in user should not see a banner
    And a logged-out user should not see a banner

Scenario: User can turn off banner using "×" button
  Given there are no banners
    And an admin creates an active banner
  When I turn off the banner
  Then I should not see "This is some banner text"

Scenario: Banner stays off when logging out and in again
  Given there are no banners
    And an admin creates an active banner
    And I turn off the banner
  When I am logged out
    And I am logged in as "newname"
  Then I should not see "This is some banner text"
  
Scenario: Logged out user can turn off banner
  Given there are no banners
    And an admin creates an active banner
    And I am logged out
  When I follow "×"
  Then I should not see "This is some banner text"
   
Scenario: User can turn off banner in preferences
  Given there are no banners
    And an admin creates an active banner
    And I am logged in as "banner_tester"
    And I set my preferences to turn off the banner showing on every page
  When I go to my user page
  Then I should not see "This is some banner text"

Scenario: User can turn off banner in preferences, but will still see a banner when an admin deactivates the existing banner and sets a new banner
  Given there are no banners
    And an admin creates an active banner
    And I am logged in as "banner_tester_2"
  When I set my preferences to turn off the banner showing on every page
    And I go to my user page
  Then I should not see "This is some banner text"
  When an admin deactivates the banner
    And an admin creates a different active banner
  When I am logged in as "banner_tester_2"
  Then I should see "This is new banner text"
  
Scenario: Admin can delete a banner and it will no longer be shown to users
  Given there are no banners
    And an admin creates an active banner
  When I am logged in as an admin
    And I am on the admin_banners page
    And I follow "Delete"
    And I press "Yes, Delete Banner"
  Then I should see "Banner successfully deleted."
    And a logged-in user should not see a banner
    And a logged-out user should not see a banner
