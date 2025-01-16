Feature: Various things on the homepage

  Scenario: Logged out

  When I am on the homepage
  Then I should see "The Archive of Our Own is a project of the Organization for Transformative Works."

  Scenario: Diversity statement

  Given I am on the homepage
  When I follow "Diversity Statement"
  Then I should see "You are welcome at the Archive of Our Own."

  Scenario: DMCA

  Given I am on the homepage
  When I follow "DMCA Policy"
  Then I should see "Filing a DMCA counternotice"

  Scenario: Donate

  Given I am on the homepage
  When I follow "Site Map"
    And I follow "Donations"
  Then I should see "There are two main ways to support the AO3 - donating your time or money"
    And I should see the page title "Donate or Volunteer"
    And I should see a link "donation to the OTW" to "https://donate.transformativeworks.org/otwgive"

  Scenario: About

    Given I am on the about page
    Then I should see the page title "About the OTW"
      And I should see a link "GitHub repository" to "https://github.com/otwcode/otwarchive"
      And I should see a link "Jira project" to "https://otwarchive.atlassian.net/browse/AO3"
