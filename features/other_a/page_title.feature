Feature: Page titles
When I browse the AO3
I want page titles to be readable

Scenario: user reads a TOS or FAQ page

  When I go to the TOS page
  Then the page title should include "Terms of Service"
  When I go to the FAQ page
  Then the page title should include "FAQ"

Scenario: Page title should respect user preference

  Given I am logged in as "author"
    And I go to my preferences page
    And I fill in "Browser page title format" with "FANDOM - AUTHOR - TITLE"
    And I press "Update"
    And I post the work "New Story" with fandom "Stargate"
  When I view the work "New Story"
  Then the page title should include "Stargate - author - New Story"

Scenario: Page title should change when tags are edited

  Given I am logged in as "author"
    And I post the work "New Story" with fandom "Stargate"
  When I view the work "New Story"
  Then the page title should include "Stargate"
  When I edit the work "New Story"
    And I fill in "Fandoms" with "Harry Potter"
    And I press "Post"
  When I view the work "New Story"
  Then the page title should include "Harry Potter"
    And the page title should not include "Stargate"

Scenario: Page title should be informative on the adult content notice page

  Given I am logged in as "author"
    And I post the 2 chapter work "New Story" with fandom "Stargate" with rating "Mature"
  When I am logged out
    And I view the work "New Story"
  Then I should see "This work could have adult content"
    And the page title should include "New Story - author - Stargate"
  When I follow the recent chapter link for the work "New Story"
  Then I should see "This work could have adult content"
    And the page title should include "New Story - Chapter 2 - author - Stargate"
