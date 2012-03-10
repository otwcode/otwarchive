@works
Feature: Import Works
  In order to have an archive full of works
  As an author
  I want to create new works by importing them

  @work_import_errors
  Scenario: Entering a bogus URL
    Given basic tags
      And I am logged in as a random user
    When I go to the import page
      And I fill in "urls" with "http://bogus"
    When I press "Import"
    Then I should see "We couldn't successfully import that work"
    When I go to the works page
    Then I should not see "We couldn't successfully import that work"
