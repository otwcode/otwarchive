@works
Feature: Edit Works Dates
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: Editing dates on a work

    Given I have loaded the fixtures
      And I am logged in as "testuser" with password "testuser"
    When I am on testuser's works page
    Then I should not see "less than 1 minute ago"
      And I should see "29 Apr 2010"
    When I follow "First work"
    Then I should see "first fandom"
      And I should see "Published:2010-04-30"
      And I should see "Edit"

    # Editing a work doesn't change the published date
    When I follow "Edit"
    Then I should see "Edit Work"
    When I fill in "content" with "first chapter content"
      And I check "chapters-options-show"
      And I fill in "work_wip_length" with "3"
      And I press "Preview"
    Then I should see "Preview Work"
      And I should see "Fandom: first fandom"
      And I should see "first chapter content"
      And I should see "Published:2010-04-30"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should see "Published:2010-04-30"
      And I should not see Updated today

    # Adding a chapter doesn't change the published date, but adds "Updated today"
    When I follow "Add Chapter"
      And I fill in "content" with "this is my second chapter"
      And I press "Preview"
    Then I should see "This is a preview of what this chapter will look like"
    When I follow "Post Chapter"
    Then I should see "Chapter has been posted"
      And I should see "Published:2010-04-30"
      And I should see Updated today
    When I am on testuser's works page
    Then I should see "less than 1 minute ago"
      And I should not see "29 Apr 2010"

    # Backdating the first chapter changes published date but not updated date
    When I edit the work "First work"
      And I check "backdate-options-show"
    Then I should see "Set this publication date for the entire work"
    When I select "1" from "work_chapter_attributes_published_at_3i"
      And I select "January" from "work_chapter_attributes_published_at_2i"
      And I select "1990" from "work_chapter_attributes_published_at_1i"
      And I press "Preview"
      And I press "Update"
    Then I should see "Published:1990-01-01"
      And I should see "first chapter content"
      And I should not see "this is my second chapter"
      And I should see Updated today

    # Published date is the same for all chapters
    When I follow "Next Chapter"
    Then I should see "Published:1990-01-01"
      And I should see Updated today
      And I should not see "first chapter content"
      And I should see "this is my second chapter"

    # Set this date for the entire work changes both published and updated dates
    When I edit the work "First work"
      And I check "backdate-options-show"
    Then I should see "Set this publication date for the entire work"
    When I select "2" from "work_chapter_attributes_published_at_3i"
      And I select "February" from "work_chapter_attributes_published_at_2i"
      And I select "1991" from "work_chapter_attributes_published_at_1i"
      And I check "work_backdate"
      And I press "Preview"
      And I press "Update"
    Then I should see "Published:1991-02-02"
      And "backdating work with previous chapters" is fixed
      #And I should see "Updated:1991-02-01"
      And I should not see Updated today
      And I should see "first chapter content"
      And I should not see "this is my second chapter"
    When I follow "Next Chapter"
    Then I should see "Published:1991-02-02"
      And "ditto" is fixed
      #And I should see "Updated:1991-02-01"
      And I should not see Updated today
      And I should not see "first chapter content"
      And I should see "this is my second chapter"
