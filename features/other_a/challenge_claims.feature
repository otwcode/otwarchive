@users
Feature: Examine challenge claims

  Scenario: Check the title of the claims page

  Given the following activated user exists
  | login         | password   |
  | scott         | password   |
  
  When I am logged in as scott with password "password"
    And I go to scott's user page
    And I follow "Claims"
  Then I should see the page title "scott - Challenge Claims"