@users
Feature: Reading count

  Scenario: only see own reading history
    Given the following activated user exists
    | login          | password   |
    | reader1        | password   |
  When I am logged in as "reader2" with password "password"
    And I go to reader1's reading page
    Then I should see "Sorry, you don't have permission"
    And I should not see "History"
  When I go to reader2's reading page
    Then I should see "History"

  Scenario: disable reading history
    also issue 1691
      Add a view count to reading items
      Counts will show on the reading history page.
      increment the count whenever you reread a story
      also updates the date

    Given I am logged in as "writer" with password "something"
      And I post the work "some work"
      And I am logged out
    When I am logged in as "fandomer" with password "password"
      And fandomer first read "some work" on "2010-05-25"
    When I go to fandomer's reading page
    Then I should see "some work"
      And I should see "Number of times viewed: 1"
      And I should see "Last viewed: 25 May 2010"
      And I follow "Preferences"
      And I uncheck "Enable Viewing History"
      And I press "Update"
    Then I should not see "My History"
    When I am on writer's works page
      And I follow "some work"
    When I am on writer's works page
      And I follow "some work"
    When I go to fandomer's reading page
    Then I should see "You have reading history disabled"
      And I should not see "some work"
    When I check "Enable Viewing History"
      And I press "Update"
    Then I should see "Your preferences were successfully updated."
      And I should see "Number of times viewed: 1"
      And I should see "Last viewed: 25 May 2010"
    When I am on writer's works page
      And I follow "some work"
    When I go to fandomer's reading page
    Then I should see "Number of times viewed: 2"
      And I should see "Last viewed: less than 1 minute ago"

  Scenario: issue 1690
    clear your whole reading history.

    Given I have loaded the fixtures
    When I am logged in as "fandomer" with password "password"
      And I am on testuser's works page
      And I follow "First work"
      And I am on testuser's works page
      And I follow "second work"
      And I am on testuser2's works page
      And I follow "fifth"
      And I follow "Proceed"
    When I go to fandomer's reading page
    Then I should see "History"
      And I should see "First work"
      And I should see "second work"
      And I should see "fifth"
      But I should not see "fourth"
    When I follow "Clear Viewing History"
      Then I should see "Your history is now cleared"
      And I should see "History"
      But I should not see "First work"
      And I should not see "second work"
      And I should not see "fifth"

  Scenario: Mark a story to read later
    
  Given I am logged in as "writer" with password "something"
  When I post the work "Testy"
  Then I should see "Work was successfully posted"
  When I am logged out
    And I am logged in as "reader" with password "something_else"
    And I view the work "Testy"
  Then I should see "Mark to read later"
  When I follow "Mark to read later"
  Then I should see "The work was marked to read later. You can find it in your history."
  When I go to reader's reading page
  Then I should see "Testy"
    And I should see "Flagged to read later"
  When I view the work "Testy"
  Then I should see "Mark as read"
  When I follow "Mark as read"
  Then I should see "The work was marked as read."
  When I go to reader's reading page
  Then I should see "Testy"
    And I should not see "Flagged to read later"
    
  Scenario: You can't mark a story to read later if you're not logged in or the author
  
  Given I am logged in as "writer" with password "something"
  When I post the work "Testy"
  Then I should see "Work was successfully posted"
  When I view the work "Testy"
  Then I should not see "Mark to read later"
    And I should not see "Mark as read"
  When I am logged out
    And I view the work "Testy"
  Then I should not see "Mark to read later"
    And I should not see "Mark as read"
    
  Scenario: Read a multi-chapter work
  
  Given I am logged in as "writer" with password "something"
    And I post the work "some work"
  When I view the work "some work"
    And I follow "Add Chapter"
    And I fill in "content" with "Second blah blah"
    And I press "Preview"
    And I follow "Post Chapter"
  Then I should see "some work"
  When I am logged out
    And I am logged in as "fandomer" with password "password"
    And I go to the works page
    And I follow "some work"
    And I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Number of times viewed: 1"
  When I follow "Delete"
  Then I should see "Work deleted from your history."
  When I go to the works page
    And I follow "some work"
  Then I should not see "Second blah blah"
  When I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Number of times viewed: 1"
  When I go to the works page
    And I follow "some work"
    And I follow "Next Chapter"
  Then I should see "Second blah blah"
  When I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Number of times viewed: 2"
  When I go to the works page
    And I follow "some work"
    And I follow "Next Chapter"
  Then I should see "Second blah blah"
  When I follow "Mark to read later"
  Then I should see "The work was marked to read later. You can find it in your history."
  When I go to fandomer's reading page
  Then I should see "some work"
    And I should see "Number of times viewed: 3"
    And I should see "(Flagged to read later.)"
