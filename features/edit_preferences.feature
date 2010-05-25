@users
Feature: Edit preferences
  In order to have an archive full of users
  As a humble user
  I want to fill out my preferences

  Scenario: View and edit preferences

  Given the following activated user exists
    | login         | password   |
    | editname      | password   |
  When I go to editname's user page
    And I follow "Profile"
  Then I should not see "My email address"
    And I should not see "My birthday"
  When I am logged in as "editname" with password "password"
  Then I should see "Hi, editname!"
    And I should see "Log out"
  When I follow "editname"
  Then I should see "My Dashboard"
    And I should see "There are no works or bookmarks under this name yet"
    And I should see "My History"
  When I follow "My Preferences"
  Then I should see "Update My Preferences"
  When I uncheck "Enable Viewing History"
    And I check "Always view entire work by default"
    And I check "Display Email Address"
    And I check "Display Date of Birth"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I follow "editname"
  Then I should see "My Dashboard"
    And I should not see "My History"
  When I follow "Log out"
    And I go to editname's user page
    And I follow "Profile"
  Then I should see "My email address"
    And I should see "My birthday"
