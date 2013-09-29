@users
Feature: Reading count

  Scenario: only see own reading history
    Given the following activated user exists
    | login          | password   |
    | first_reader        | password   |
  When I am logged in as "second_reader"
    And I go to first_reader's reading page
    Then I should see "Sorry, you don't have permission"
    And I should not see "History" within "div#dashboard"
  When I go to second_reader's reading page
    Then I should see "History" within "div#dashboard"

  Scenario: disable reading history
    also issue 1691
      Add a view count to reading items
      Counts will show on the reading history page.
      increment the count whenever you reread a story
      also updates the date

    Given I am logged in as "writer"
      And I post the work "some work"
      And I am logged out
    When I am logged in as "fandomer"
      And fandomer first read "some work" on "2010-05-25"
    When I go to fandomer's reading page
    Then I should see "some work"
      And I should see "Viewed once"
      And I should see "Last viewed: 25 May 2010"
      And I follow "Preferences"
      And I uncheck "Turn on Viewing History"
      And I press "Update"
    Then I should not see "My History"
    When I am on writer's works page
      And I follow "some work"
    When I am on writer's works page
      And I follow "some work"
    When the reading rake task is run
      And I go to fandomer's reading page
    Then I should see "You have reading history disabled"
      And I should not see "some work"
    When I check "Turn on Viewing History"
      And I press "Update"
    Then I should see "Your preferences were successfully updated."
      And I should see "Viewed once"
      And I should see "Last viewed: 25 May 2010"
    When I am on writer's works page
      And I follow "some work"
    When the reading rake task is run
      And I go to fandomer's reading page
    Then I should see "Viewed 2 times"
      And I should see "Last viewed: less than 1 minute ago"

  Scenario: issue 1690

    Given I have loaded the fixtures
      And the work indexes are updated
    When I am logged in as "fandomer"
      And I am on testuser's works page
      And I follow "First work"
      And I am on testuser's works page
      And I follow "second work"
      And I am on testuser2's works page
      And I follow "fifth"
      And I should see "fifth by testuser2"
      And I follow "Proceed"
      And the reading rake task is run
    When I go to fandomer's reading page
    Then I should see "History" within "div#dashboard"
      And I should see "First work"
      And I should see "second work"
      And I should see "fifth"
      But I should not see "fourth"
    When I follow "Clear History"
      Then I should see "Your history is now cleared"
      And I should see "History" within "div#dashboard"
      But I should not see "First work"
      And I should not see "second work"
      And I should not see "fifth"

  Scenario: Mark a story to read later

  Given I am logged in as "writer"
  When I post the work "Testy"
  Then I should see "Work was successfully posted"
  When I am logged out
    And I am logged in as "reader"
    And I view the work "Testy"
  Then I should see "Mark for later"
  When I follow "Mark for later"
  Then I should see "This work was marked for later. You can find it in your history. (The work may take a short while to show up there.)"
  When the reading rake task is run
    And I go to reader's reading page
  Then I should see "Testy"
    And I should see "(Marked for later.)"
  When I view the work "Testy"
  Then I should see "Mark as read"
  When I follow "Mark as read"
  Then I should see "This work was marked for later. You can find it in your history. (The work may take a short while to show up there.)"
  When the reading rake task is run
    And I go to reader's reading page
  Then I should see "Testy"
    And I should not see "(Marked for later.)"

  Scenario: You can't mark a story to read later if you're not logged in or the author

  Given I am logged in as "writer"
  When I post the work "Testy"
  Then I should see "Work was successfully posted"
  When I view the work "Testy"
  Then I should not see "Mark for later"
    And I should not see "Mark as read"
  When I am logged out
    And I view the work "Testy"
  Then I should not see "Mark for later"
    And I should not see "Mark as read"

  Scenario: Read a multi-chapter work

  Given I am logged in as "writer"
    And I post the work "some work"
  When I view the work "some work"
    And I follow "Add Chapter"
    And I fill in "content" with "Second blah blah"
    And I press "Preview"
    And I press "Post"
  Then I should see "some work"
  When I am logged out
    And I am logged in as "fandomer"
    And I go to the works page
    And I follow "some work"
  When the reading rake task is run
    And I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Viewed once"
  When I follow "Delete"
  Then I should see "Work deleted from your history."
  When I go to the works page
    And I follow "some work"
  Then I should not see "Second blah blah"
  When the reading rake task is run
    And I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Viewed once"
  When I go to the works page
    And I follow "some work"
    And I follow "Next Chapter"
  Then I should see "Second blah blah"
  When the reading rake task is run
    And I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Viewed 2 times"
  When I go to the works page
    And I follow "some work"
    And I follow "Next Chapter"
  Then I should see "Second blah blah"
  When I follow "Mark for later"
  Then I should see "This work was marked for later. You can find it in your history. (The work may take a short while to show up there.)"
  When the reading rake task is run
    And I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Viewed 3 times"
    And I should see "(Marked for later.)"
