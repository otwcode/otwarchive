Feature: Page titles
When I browse the AO3
I want page titles to be readable

Scenario: user reads a TOS or FAQ page

  When I go to the TOS page
  Then the page title should include "TOS"
  When I go to the FAQ page
  Then the page title should include "FAQ"

  
