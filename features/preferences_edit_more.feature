@users
Feature: Preferences

  Scenario: View and edit preferences - show/hide mature content warning

  Given the following activated users exist
    | login          | password   |
    | mywarning1     | password   |
    | mywarning2     | password   |
    And a rating exists with name: "Mature", canonical: true, adult: true
  When I am logged in as "mywarning1" with password "password"
  And I post the work "Adult Work by mywarning1"
  When I edit the work "Adult Work by mywarning1"
    And I select "Mature" from "Rating"
    And I press "Preview"
    And I press "Update"
  When I follow "Log out"
    And I am logged in as "mywarning2" with password "password"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I check "Show me adult content without prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should not see "This work may contain adult content"
    And I should see "Rating: Mature"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I uncheck "Show me adult content without prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should see "This work potentially has adult content"
    And I should not see "Rating: Mature"

  Scenario: hide user generated view css
  Given basic tags
    And I am logged in as "tasteless" with password "something"
  When I post the work "Big and Loud"
    And I go to the "Big and Loud" work page
  Then I should find "ugv-style-creator.css"
    And I should not see "Switch to creator's style"
  When I follow "Switch to light style"
  Then I should not find "ugv-style-creator.css"
    And I should see "Switch to creator's style"
  When I follow "tasteless"
    And I follow "My Preferences"
  Then the "Disable User Generated Styles" checkbox should not be checked
  When I check "Disable User Generated Styles"
    And I press "Update"
  When I go to the "Big and Loud" work page
  Then I should not find "ugv-style-creator.css"
    And I should not see "Switch to light style"
  When I follow "Switch to creator's style"
  Then I should find "ugv-style-creator.css"
    And I should see "Switch to light style"
  Given I am logged out
    And I am logged in as "tasteful" with password "something"
    And I go to the "Big and Loud" work page
  Then I should find "ugv-style-creator.css"
    And I should not see "Switch to creator's style"
  When I follow "Switch to light style"
    Then I should not find "ugv-style-creator.css"
  When I follow "Switch to creator's style"
    Then I should find "ugv-style-creator.css"
  When I follow "tasteful"
    And I follow "My Preferences"
  When I check "Disable User Generated Styles"
    And I press "Update"
  When I go to the "Big and Loud" work page
  Then I should not find "ugv-style-creator.css"
    And I should not see "Switch to light style"
  When I follow "Switch to creator's style"
    Then I should find "ugv-style-creator.css"
  When I follow "Switch to light style"
    Then I should not find "ugv-style-creator.css"
  When I follow "tasteful"
    And I follow "My Preferences"
  When I uncheck "Disable User Generated Styles"
    And I press "Update"
  When I go to the "Big and Loud" work page
  Then I should find "ugv-style-creator.css"
  Given I am logged out
    And I go to the "Big and Loud" work page
  Then I should find "ugv-style-creator.css"
    And I should not see "Switch to creator's style"
  When I follow "Switch to light style"
    Then I should not find "ugv-style-creator.css"
  When I follow "Switch to creator's style"
    Then I should find "ugv-style-creator.css"
