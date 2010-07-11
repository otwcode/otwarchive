@users
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
    And I check "Show Me Adult Content Without Prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should not see "This work may contain adult content"
    And I should see "Rating: Mature"
  When I follow "mywarning2"
    And I follow "My Preferences"
    And I uncheck "Show Me Adult Content Without Prompting"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"
  When I go to the works page
    And I follow "Adult Work by mywarning1"
  Then I should see "This work potentially has adult content"
    And I should not see "Rating: Mature"
