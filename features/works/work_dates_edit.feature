@works
Feature: Edit Works Dates
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: Editing dates on a work
    When "Issue 2542" is fixed
#    Given I have loaded the fixtures
#      And I am logged in as "testuser" with password "testuser"
#      And all search indexes are updated
#    When I am on testuser's works page
#    Then I should not see "less than 1 minute ago"
#      And I should see "29 Apr 2012"
#    When I follow "First work"
#    Then I should see "first fandom"
#      And I should see "Edit"

    # Editing a work doesn't change the published date
#    When I follow "Edit"
#    Then I should see "Edit Work"
#    When I fill in "content" with "first chapter content"
#      And I check "chapters-options-show"
#      And I fill in "work_wip_length" with "3"
#      And I press "Preview"
#    Then I should see "Preview"
#      And I should see "Fandom: first fandom"
#      And I should see "first chapter content"
#      And I should see "Published:2010-04-30"
#    When I update the work
#    Then I should see "Work was successfully updated."
#      And I should see "Published:2010-04-30"
#      And I should not see Updated today

    # Adding a chapter doesn't change the published date, but adds "Updated today"
#    When I follow "Add Chapter"
#      And I fill in "content" with "this is my second chapter"
#      And I press "Preview"
#    Then I should see "This is a draft showing what this chapter will look like"
#    When I press "Post"
#    Then I should see "Chapter was successfully posted."
#      And I should see "Published:2010-04-30"
#      And I should see Updated today
#    When I am on testuser's works page
#    Then I should see "less than 1 minute ago"
#      And I should not see "29 Apr 2010"

    # Backdating the first chapter (the Work) changes published date but not the updated date
#    When I edit the work "First work"
#      And I check "backdate-options-show"
#    When I select "1" from "work_chapter_attributes_published_at_3i"
#      And I select "January" from "work_chapter_attributes_published_at_2i"
#      And I select "1990" from "work_chapter_attributes_published_at_1i"
#      And I press "Preview"
#      And I press "Update"
#    Then I should see "Published:1990-01-01"
#      And I should see "first chapter content"
#      And I should not see "this is my second chapter"
#      And I should see Updated today

  # The entire work is backdated. Now, I want to edit chapter two to have a "Chapter Publication 
  # Date" date set to January 16th, 2013. This should not affect the work's published date, but
  # the work's updated date should change to match the most recent chapter pub date
#    When I follow "Next Chapter"
#      And I follow "Edit Chapter"
#      And I select "16" from "chapter_published_at_3i"
#      And I select "January" from "chapter_published_at_2i"
#      And I select "2013" from "chapter_published_at_1i"
#      And I press "Preview"
#      And I press "Update"
#    Then I should see "Updated:2013-01-16"
#      And I should see "Published:1990-01-01"
#    When I follow "Full-page index"
#      Then I should see "1. Chapter 1 (1990-01-01)"
#      And I should see "2. Chapter 2 (2013-01-16)"
