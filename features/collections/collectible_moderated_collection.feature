@bookmarks @collections @works

Feature: Collectible items in moderated collections
  As a user
  I want to add my items to moderated collections

  Background:
    Given I have a moderated collection "Various Penguins"
      And I am logged in as a random user

  Scenario: Add my work to a moderated collection with the Add to Collections 
  button
    Given I post the work "Blabla"
    When I add my work to the collection
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Works (0)"
      And I should not see "Blabla"

  Scenario: Add my work to a moderated collection by editing the work
    Given I post the work "Blabla"
    When I edit the work "Blabla"
      And I fill in "Post to Collections / Challenges" with "various_penguins"
      And I press "Preview"
    Then I should see "the moderated collection 'Various Penguins'"
    When I press "Update"
    Then I should see "the moderated collection 'Various Penguins'"

  @old-search
  Scenario: Add my bookmark to a moderated collection
    Given I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarks (0)"
      And I should not see "Tundra penguins"

  # This is the same as the test above, but with the sidebar text updated to
  # reflect the new bookmarked item listings.
  @new-search
  Scenario: Add my bookmark to a moderated collection
    Given I have a bookmark for "Tundra penguins"
    When I add my bookmark to the collection "Various_Penguins"
    Then I should see "until it has been approved by a moderator."
    When I go to "Various Penguins" collection's page
    Then I should see "Bookmarked Items (0)"
      And I should not see "Tundra penguins"

  Scenario: Bookmarks of deleted items are included on a moderated collection's
  Awaiting Approval Manage Items page
    Given I have a bookmark of a deleted work
      And I add my bookmark to the collection "Various_Penguins"
    When I am logged in as the owner of "Various Penguins"
      And I view the awaiting approval collection items page for "Various Penguins"
    Then I should see "Bookmark of deleted item"
      And I should see "This has been deleted, sorry!"

