@works
Feature: Share Works
  Testing the "Share" button on works, with Javascript emulation

  Scenario: Share a work
    Given I have a work "Blabla"
    When I view the work "Blabla"
    Then I should see "Share"
    When I follow "Share"
    Then I should see "Copy and paste the following code to link back to this work (ctrl A / cmd A will select all)"
      And I should see "><strong>Blabla</strong></a> (6 words) b"
      And I should see "by <a href="
      And I should see 'Fandom: <a href="http://www.example.com/tags/Stargate' within "#share"
      And I should see "Rating: Not Rated" within "#share"
      And I should see "Warning: No Archive Warnings Apply" within "#share"
      And I should not see "Series:" within "#share"
      And I should not see "Relationships:" within "#share"
      And I should not see "Characters:" within "#share"
      And I should not see "Summary:" within "#share"
