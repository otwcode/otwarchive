@users
Feature: Edit preferences
  In order to have an archive full of users
  As a humble user
  I want to fill out my preferences

  Scenario: View and edit preferences - viewing history, personal details, view entire work

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
  When I post the work "This has two chapters"
  And I follow "Add chapter"
    And I fill in "content" with "Secondy chapter"
    And I press "Preview"
    And I press "Post"
  Then I should not see "Secondy chapter"
  When I follow "editname"
  Then I should see "My Dashboard"
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
  When I go to the works page
    And I follow "This has two chapters"
  Then I should see "Secondy chapter"
  When I follow "Log out"
    And I go to editname's user page
    And I follow "Profile"
  Then I should see "My email address"
    And I should see "My birthday"
  When I go to the works page
    And I follow "This has two chapters"
  Then I should not see "Secondy chapter"
  
  Scenario: View and edit preferences - show/hide warnings and tags

  Given the following activated users exist
    | login          | password   |
    | mywarning1     | password   |
    | mywarning2     | password   |
  When I am logged in as "mywarning1" with password "password"
  When I post the work "This work has warnings and tags"
  When I follow "Log out"
  When I am logged in as "mywarning2" with password "password"
    And I post the work "This also has warnings and tags"
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "mywarning2"
  Then I should see "My Dashboard"
  When I follow "My Preferences"
  Then I should see "Update My Preferences"
  When I check "Hide Warnings"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should not see "Warning: No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I check "Hide Freeform Tags"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should see "Scary tag"
    And I should see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should not see "Warning: No Archive Warnings Apply"
    And I should see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I uncheck "Hide Warnings"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
  Then I should see "No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should see "Show additional tags"
  When I follow "This work has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should not see "Scary tag"
    And I should see "Show additional tags"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "Warning: No Archive Warnings Apply"
    And I should not see "Show warnings"
    And I should see "Scary tag"
    And I should not see "Show additional tags"
