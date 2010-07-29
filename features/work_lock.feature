@works
Feature: Locking works to archive users only
  In order to keep my works under the radar
  As a registered archive user
  I should be able to make my works visible only to other registered users

Scenario: Posting locked work
    Given I am logged in as "fandomer" with password "password"
      And basic tags
      And I go to the new work page
      And I select "Not Rated" from "Rating"
      And I check "No Archive Warnings Apply"
      And I fill in "Fandoms" with "Supernatural"
      And I fill in "Characters" with "Sammy"
      And I fill in "Work Title" with "Awesomeness"
      And I fill in "content" with "The story of how they met and how they got into trouble"
      And I check "work_restricted"
    When I press "Preview"
    Then I should see the "title" text "Restricted" within "h2.title"
    When I press "Post"
    Then I should see the "alt" text "(Restricted)" within "h2.title"
    When I go to the works page
    Then I should see "Awesomeness" within "h4"
      And I should see the "alt" text "(Restricted)" within "h4"
    When I am logged out
      And I go to the works page
    Then I should not see "Awesomeness"
      And I should not see the "alt" text "(Restricted)"
    When I am on fandomer's works page
    Then I should not see "Awesomeness"
    When I am logged in as "testuser" with password "password"
      And I am on fandomer's works page
    Then I should see "Awesomeness"

Scenario: Editing posted work
    Given I am logged in as "fandomer" with password "password"
      And I post the work "Sad generic work"
    When I am logged out
      And I go to fandomer's works page
    Then I should see "Sad generic work"
    When I am logged in as "fandomer" with password "password"
      And I edit the work "Sad generic work"
      And I check "work_restricted"
    When I press "Preview"
    Then I should see the "title" text "Restricted" within "h2.title"
    When I press "Update"
    Then I should see the "alt" text "(Restricted)" within "h2.title"
    When I go to the works page
    Then I should see "Sad generic work" within "h4"
      And I should see the "alt" text "(Restricted)" within "h4"
    When I am logged out
      And I go to the works page
    Then I should not see "Sad generic work"
      And I should not see the "alt" text "(Restricted)"
    When I am logged in as "testuser" with password "password"
      And I go to the works page
    Then I should see "Sad generic work"
    When I am logged out
      And I am logged in as "fandomer" with password "password"
      And I edit the work "Sad generic work"
      And I fill in "Notes" with "Random blather"
      And I press "Preview"
    Then I should see the "alt" text "(Restricted)" within "h2.title"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should see the "alt" text "(Restricted)" within "h2.title"
    When I edit the work "Sad generic work"
      And I uncheck "work_restricted"
      And I press "Preview"
    Then I should not see the "alt" text "(Restricted)"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should not see the "alt" text "(Restricted)"
    When I am logged out
      And I go to the works page
    Then I should see "Sad generic work"
