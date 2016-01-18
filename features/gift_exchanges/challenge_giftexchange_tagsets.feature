@collections
Feature: Gift Exchange Challenge with Tag Sets
  In order to have more fics for my fandom
  As a humble user
  I want to run a gift exchange with tag sets so I can make it single-fandom

  Scenario: Tagsets show up in Challenge metadata
    Given I am logged in as "mod1"
      And I have created the gift exchange "Cabbot Cove Remixes"
      And I go to the tagsets page
      And I follow the add new tagset link
      And I fill in "Title" with "Angela Lansbury"
      And I submit
      And I go to "Cabbot Cove Remixes" collection's page
      And I follow "Profile"
      And I should see "Tag Set:"
      And I should see "Standard Challenge Tags"
    When I edit settings for "Cabbot Cove Remixes" challenge
      And I fill in "Tag Sets To Use:" with "Angela Lansbury"
      And I press "Update"
    Then I should see "Tag Sets:"
      And I should see "Standard Challenge Tags"
      And I should see "Angela Lansbury"
    When I edit settings for "Cabbot Cove Remixes" challenge
      And I check "Standard Challenge Tags"
      And I check "Angela Lansbury"
      And I press "Update"
    Then I should not see "Tag Sets:"
      And I should not see "Tag Set:"
      And I should not see "Standard Challenge Tags"
      And I should not see "Angela Lansbury"
