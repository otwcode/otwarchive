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
    When I follow "My History"
    Then I should see "Number of times viewed: 1"
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

