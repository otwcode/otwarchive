@tags
Feature: Search Tags
  In order to figure out how to use cucumber with thinking sphinx
  As a humble coder
  I want to figure out how to test tag search

  Scenario: Search tags
	Given I have a Character tag named "myname"
        And the Sphinx indexes are updated
        When I am on the tag search page
        And I fill in "tag_search" with "myname"
        When I press "Search tags"
        Then I should see "1 Found"
        And I should see "myname (0)"
