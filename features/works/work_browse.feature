@works @browse
Feature: browsing works from various contexts

Scenario: browsing works with incorrect page params in query string

  Given I am logged in as a random user
    And a fandom exists with name: "Johnny Be Good", canonical: true
    And I post the work "Whatever" with fandom "Johnny Be Good"
  When I browse the "Johnny Be Good" works with an empty page parameter
  Then I should see "1 Work"

Scenario: The recent chapter link should point to the last posted chapter even
if there is a draft chapter

  Given I am logged in as a random user
    And a fandom exists with name: "Canonical Fandom", canonical: true
    And I post the 2 chapter work "My WIP" with fandom "Canonical Fandom"
  When I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "My WIP"
  Then I should find myself on Chapter 2 of the work "My WIP"
  When a draft chapter is added to "My WIP"
    And I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "My WIP"
  Then I should find myself on Chapter 2 of the work "My WIP"

Scenario: The recent chapter link in a work's blurb should show the adult
content notice to visitors who are not logged in

  Given I am logged in as a random user
    And a rating exists with name: "Mature", canonical: true, adult: true
    And a fandom exists with name: "Canonical Fandom", canonical: true
    And I post the 3 chapter work "WIP" with fandom "Canonical Fandom" with rating "Mature"
  When I am logged out
    And I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "WIP"
  Then I should see "adult content"
  When I follow "Proceed"
  Then I should find myself on Chapter 3 of the work "WIP"
    And I should see "Hits: 1"

Scenario: The recent chapter link in a work's blurb should honor the logged-in
user's "Show me adult content without checking" preference

  Given I am logged in as a random user
    And a rating exists with name: "Mature", canonical: true, adult: true
    And a fandom exists with name: "Canonical Fandom", canonical: true
    And I post the 2 chapter work "WIP" with fandom "Canonical Fandom" with rating "Mature"
  When I am logged in as "adultuser"
    And I set my preferences to show adult content without warning
    And I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "WIP"
  Then I should not see "adult content"
    And I should find myself on Chapter 2 of the work "WIP"
  When I set my preferences to warn before showing adult content
    And I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "WIP"
  Then I should see "adult content"
  When I follow "Proceed"
  Then I should find myself on Chapter 2 of the work "WIP"

Scenario: The recent chapter link in a work's blurb should point to
chapter-by-chapter mode even if the logged-in user's preference is "Show the
whole work by default"

  Given I am logged in as a random user
    And a fandom exists with name: "Canonical Fandom", canonical: true
    And I post the 2 chapter work "WIP" with fandom "Canonical Fandom" with rating "Mature"
  When I am logged in as "fullworker"
    And I set my preferences to View Full Work mode by default
    And I browse the "Canonical Fandom" works
    And I follow the recent chapter link for the work "WIP"
  Then I should find myself on Chapter 2 of the work "WIP"
