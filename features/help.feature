@help
Feature: Help
  In order to get help
  As a humble user
  I want to read help links

Scenario: clicking the help popup for moderated collection
  
  Given I am logged in as "first_user"
  When I go to the collections page
  When I follow "New Collection"
    And I follow "Collection moderated"
  Then I should see "By default, collections are not moderated"
