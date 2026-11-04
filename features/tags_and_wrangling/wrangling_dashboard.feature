@tags @tag_wrangling
Feature: Wrangling dashboard sidebar
  The sidebar with wrangling links is only shown to people who can wrangle,
  and only on tag wrangling pages.

  Scenario: Tag wrangler sees the full dashboard on the wrangling tools page
    Given I am logged in as a tag wrangler
    When I go to the wrangling tools page
    Then I should see "Wrangling Home" within "#dashboard"
      And I should see "Wrangling Tools" within "#dashboard"
      And I should see "Wranglers" within "#dashboard"
      And I should see "Search Tags" within "#dashboard"
      And I should see "New Tag" within "#dashboard"
      And I should see "Fandoms by media" within "#dashboard"
      And I should see "Characters by fandom" within "#dashboard"
      And I should see "Relationships by fandom" within "#dashboard"
      And I should see "Freeforms by fandom" within "#dashboard"
      And I should see "Unsorted Tags" within "#dashboard"
      And the main content should have the dashboard class

  Scenario: Tag wrangler sees the full dashboard on the unsorted tags page
    Given I am logged in as a tag wrangler
    When I go to the unsorted tags page
    Then I should see "Wrangling Home" within "#dashboard"
      And I should see "Fandoms by media" within "#dashboard"
      And I should see "Unsorted Tags" within "#dashboard"

  Scenario: Tag wrangler sees the tag's uses on the tag edit page
    Given I am logged in as a tag wrangler
      And a canonical fandom "Doctor Who"
    When I go to the "Doctor Who" tag edit page
    Then I should see "Wrangling Home" within "#dashboard"
      And I should see "Works" within "#dashboard"
      And I should see "Bookmarks" within "#dashboard"
      And I should see "Taggings Count" within "#dashboard"
      And I should not see "Fandoms by media" within "#dashboard"

  Scenario: Tag wrangler sees only the first group of links on the wranglers page
    Given I am logged in as a tag wrangler
    When I go to the wranglers page
    Then I should see "Wrangling Home" within "#dashboard"
      And I should see "Wrangling Tools" within "#dashboard"
      And I should see "Search Tags" within "#dashboard"
      And I should not see "Fandoms by media" within "#dashboard"
      And the main content should have the dashboard class

  Scenario: Tag Wrangling admin sees the dashboard without the wrangling home link
    Given I am logged in as a "tag_wrangling" admin
    When I go to the wrangling tools page
    Then I should see "Wrangling Tools" within "#dashboard"
      And I should see "Wranglers" within "#dashboard"
      And I should see "New Tag" within "#dashboard"
      And I should see "Fandoms by media" within "#dashboard"
      And I should not see "Wrangling Home" within "#dashboard"
      And the main content should have the dashboard class
    When I go to the unsorted tags page
    Then I should see "Unsorted Tags" within "#dashboard"
      And I should not see "Wrangling Home" within "#dashboard"

  Scenario: Tag Wrangling admin sees the tag's uses on the tag edit page
    Given I am logged in as a "tag_wrangling" admin
      And a canonical fandom "Doctor Who"
    When I go to the "Doctor Who" tag edit page
    Then I should see "Taggings Count" within "#dashboard"
      And I should not see "Wrangling Home" within "#dashboard"

  Scenario: Admin without wrangling access does not see the dashboard
    Given I am logged in as a "support" admin
      And a canonical fandom "Doctor Who"
    When I view the tag "Doctor Who"
    Then I should not see the wrangling dashboard
      And the main content should not have the dashboard class

  Scenario: Regular user does not see the dashboard on tag pages
    Given I am logged in as "regular_user"
      And a canonical fandom "Doctor Who"
    When I view the tag "Doctor Who"
    Then I should see "Doctor Who"
      And I should not see the wrangling dashboard
      And the main content should not have the dashboard class
    When I go to the tags page
    Then I should not see the wrangling dashboard

  Scenario: Logged out user does not see the dashboard on tag pages
    Given a canonical fandom "Doctor Who"
    When I view the tag "Doctor Who"
    Then I should see "Doctor Who"
      And I should not see the wrangling dashboard

  Scenario: Tag wrangler does not see the dashboard on a tag's comments page
    Given I am logged in as a tag wrangler
      And a canonical fandom "Doctor Who"
    When I view the tag "Doctor Who"
      And I follow " comments"
    Then I should see "Reading Comments on Doctor Who"
      And I should not see the wrangling dashboard
      And the main content should not have the dashboard class
