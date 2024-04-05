@series
Feature: Rearrange works within a series
  In order to manage parts of a series
  As a humble series writer
  I want to be able to reorder the parts of my series

  Scenario: Rearrange parts of a series.
    Given I am logged in as "author"
      And I post the work "A Bad, Bad Day" as part of a series "Tale of Woe"
    Then I should see "Part 1 of Tale of Woe"
    When I view the series "Tale of Woe"
    Then I should see "A Bad, Bad Day"
    When I post the work "A Bad, Bad Night" as part of a series "Tale of Woe"
    Then I should see "Part 2 of Tale of Woe"
    When I post the work "Things Get Worse" as part of a series "Tale of Woe"
    Then I should see "Part 3 of Tale of Woe"
    When I view the series "Tale of Woe"
      And I follow "Reorder Series"
    Then I should see "Manage Series: Tale of Woe"
      And I should see "1. A Bad, Bad Day"
      And I should see "2. A Bad, Bad Night"
      And I should see "3. Things Get Worse"
    When I fill in "serial_0" with "3"
      And I fill in "serial_1" with "1"
      And I fill in "serial_2" with "2"
      And I press "Update Positions"
    Then I should see "Series order has been successfully updated"
    When I follow "Reorder Series"
      And I should see "1. A Bad, Bad Night"
      And I should see "2. Things Get Worse"
      And I should see "3. A Bad, Bad Day"

  @javascript
  Scenario: Reordering series by drag and drop updates work blurbs and meta correctly.
    Given I am logged in as "author"
      And I post the work "A Bad, Bad Day" as part of a series "Tale of Woe"
      And I post the work "A Bad, Bad Night" as part of a series "Tale of Woe"
      And I post the work "Things Get Worse" as part of a series "Tale of Woe"
    # Blurbs
    When I view the series "Tale of Woe"
      Then I should see "Part 1 of Tale of Woe" within ".work.blurb:first-child"
      Then I should see "Part 2 of Tale of Woe" within ".work.blurb:nth-child(2)"
      Then I should see "Part 3 of Tale of Woe" within ".work.blurb:nth-child(3)"
    # Meta
    When I view the work "A Bad, Bad Day"
    Then I should see "Part 1 of Tale of Woe"
    When I view the work "A Bad, Bad Night"
    Then I should see "Part 2 of Tale of Woe"
    When I view the work "Things Get Worse"
    When I view the series "Tale of Woe"
      And I follow "Reorder Series"
      And I reorder the 2nd work to be below the 3rd work in the series
      And I press "Update Positions"
    Then I should see "Series order has been successfully updated"
    # Blurbs
      And I should see "Part 1 of Tale of Woe" within ".work.blurb:first-child"
      And I should see "Part 2 of Tale of Woe" within ".work.blurb:nth-child(2)"
      And I should see "Part 3 of Tale of Woe" within ".work.blurb:nth-child(3)"
    When I follow "Reorder Series"
    Then I should see "1. A Bad, Bad Day"
      And I should see "2. Things Get Worse"
      And I should see "3. A Bad, Bad Night"
    # Meta
    When I view the work "A Bad, Bad Day"
    When I view the work "A Bad, Bad Day"
    Then I should see "Part 1 of Tale of Woe"
    When I view the work "Things Get Worse"
    Then I should see "Part 2 of Tale of Woe"
    When I view the work "A Bad, Bad Night"
    Then I should see "Part 3 of Tale of Woe"
