@works
Feature: Share Works
  Testing the "Share" button on works, with Javascript emulation

  Scenario: Share a work

  Scenario: Creating a new minimally valid work
    Given basic tags
      And I am logged in as "newbie" with password "password"
    When I go to the new work page
    Then I should see "Post New Work"
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I uncheck "Choose Not To Use Archive Warnings"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Work Title" with "All Hell Breaks Loose"
      And I fill in "content" with "Bad things happen, etc."
    When I press "Preview"
    Then I should see "Preview Work"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I go to the works page
    Then I should see "All Hell Breaks Loose"
    When I follow "All Hell Breaks Loose"
    Then I should see "Share"
    When I follow "Share"
    Then I should see "Copy and paste to link back to this work: (CTRL/CMD-A will select all)"
      And I should see "><strong>All Hell Breaks Loose</strong></a> (4 words) b"
      And I should see "by <a href="
      And I should see 'profile"><img alt="favicon" border="0" src="http://www.example.com/favicon.ico'
      And I should see 'Fandom: <a href="http://www.example.com/tags/Supernatural">Supernatural' within "#share"
      And I should see "Rating: Not Rated" within "#share"
      And I should see "Warning: No Archive Warnings Apply" within "#share"
      And I should not see "Relationships: " within "#share"
      And I should not see "Characters: " within "#share"
      And I should not see "Summary: " within "#share"
