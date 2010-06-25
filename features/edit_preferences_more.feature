@wip
  Scenario: View and edit preferences - show/hide mature content warning

  Given the following activated users exist
    | login          | password   |
    | mywarning1     | password   |
    | mywarning2     | password   |
    And a warning exists with name: "No Archive Warnings Apply", canonical: true
    And a rating exists with name: "Not Rated", canonical: true
    And a rating exists with name: "Mature", canonical: true, adult: true
  When I am logged in as "mywarning1" with password "password"
  Then I should see "Hi, mywarning1!"
    And I should see "Log out"
  When I post the work "This work has warnings and tags"
  Then I should see "This work has warnings and tags"
  When I follow "Log out"
    And I am logged in as "mywarning2" with password "password"
    And I post the work "This also has warnings and tags"
  Then I should see "This also has warnings and tags"
  When I edit the work "This also has warnings and tags"
    And I select "Mature" from "Rating"
    And I press "Preview"
    And I press "Update"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I check "Show Me Adult Content Without Prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should not see "This work may contain adult content"
    And I should see "Rating: Mature"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I uncheck "Show Me Adult Content Without Prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "This also has warnings and tags"
  Then I should see "This work may contain adult content"
    And I should not see "Rating: Mature"
