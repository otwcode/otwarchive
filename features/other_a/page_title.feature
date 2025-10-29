Feature: Page titles
When I browse the AO3
I want page titles to be readable

Background:

  Given the app name is "Example Archive"

Scenario: An index page uses only the controller name in the default browser page title

  Given a fandom exists with name: "No Fandom", canonical: true
  When I go to the tags page
  Then I should see the page title "Tags | Example Archive"

Scenario: A non-index page uses the action and controller names in the default browser page title

  When I am logged in as "user"
    And I go to the new work page
  Then I should see the page title "New Work | Example Archive"

Scenario: user reads a TOS or FAQ page

  When I go to the TOS page
  Then the page title should include "Terms of Service | Example Archive"
  When I go to the FAQ page
  Then the page title should include "Archive FAQs | Example Archive"

Scenario: Work page title should respect user preference

  Given I am logged in as "author"
    And I follow "My Preferences"
    And I fill in "Browser page title format" with "FANDOM - AUTHOR - TITLE"
    And I press "Update"
    And I post the work "New Story" with fandom "Stargate"
  When I view the work "New Story"
  Then the page title should include "Stargate - author - New Story [Example Archive]"

Scenario: Work page title should change when tags are edited

  Given I am logged in as "author"
    And I post the work "New Story" with fandom "Stargate"
  When I view the work "New Story"
  Then the page title should include "Stargate"
  When I edit the work "New Story"
    And I fill in "Fandoms" with "Harry Potter"
    And I press "Update"
  When I view the work "New Story"
  Then the page title should include "Harry Potter"
    And the page title should not include "Stargate"

Scenario: Work page title should be informative on the adult content notice page

  Given I am logged in as "author"
    And I post the 2 chapter work "New Story" with fandom "Stargate" with rating "Mature"
  When I am logged out
    And I view the work "New Story"
  Then I should see "This work could have adult content"
    And the page title should include "New Story - author - Stargate [Example Archive]"
  When I follow the recent chapter link for the work "New Story"
  Then I should see "This work could have adult content"
    And the page title should include "New Story - Chapter 2 - author - Stargate [Example Archive]"

Scenario: Inbox has the expected browser page title

  When I am logged in as "boxer"
    And I go to boxer's inbox page
  Then I should see the page title "boxer - Inbox | Example Archive"

Scenario: New tag set page has the expected browser page title

  When I am logged in as "user"
  When I go to the new tag set page
  Then I should see the page title "New Owned Tag Set | Example Archive"
