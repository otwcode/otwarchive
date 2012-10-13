@works @tags
Feature: Edit Works
  In order to have an archive full of works
  As an author
  I want to edit existing works

  Scenario: You can't edit a work unless you're logged in and it's your work
    Given I have loaded the fixtures
    # I'm not logged in
    When I view the work "First work"
    Then I should not see "Edit"
    Given I am logged in as "testuser" with password "testuser"
    # This isn't my work
    When I view the work "fourth"
    Then I should not see "Edit"  
    When I am on testuser's works page
    # These are my works and should all have edit links on the blurbs
    Then I should see "Edit"
    When I follow "First work"
    # This is my individual work and should have an edit link on the show page
    Then I should see "first fandom" 
      And I should see "Edit"
      # make sure this tag isn't on before we add it
      And I should not see "new tag"
    When I follow "Edit"
    Then I should see "Edit Work"
    When I fill in "work_freeform" with "new tag"
      And I fill in "content" with "first chapter content"
      And I press "Preview"
    Then I should see "Preview"
      And I should see "Fandom: first fandom"
      And I should see "Additional Tags: new tag"
      And I should see "first chapter content"
    When I press "Update"
    Then I should see "Work was successfully updated."
    When I go to testuser's works page
    Then I should see "First work"
      And I should see "first fandom"
      And I should see "new tag"
    When I follow "Edit"
      And I follow "Add Chapter"
      And I fill in "content" with "second chapter content"
      And I press "Preview"
    Then I should see "preview of what this chapter"
      And I should see "second chapter content"
    When I press "Post Chapter"
    Then I should see "Chapter has been posted!"
      And I should see "first chapter content"
      And I should not see "second chapter content"
    When I follow "Edit"
    Then I should not see "chapter content"
    When I follow "1"
      And I fill in "content" with "first chapter new content"
      And I press "Preview"
    Then I should see "first chapter new content"
    When I press "Update"
    Then I should see "Chapter was successfully updated."
      And I should see "first chapter new content"
      And I should not see "second chapter content"
    When I follow "Edit"
      And I follow "2"
      And I fill in "content" with "second chapter new content"
      And I press "Preview"
    And I press "Cancel"
      Then I should see "second chapter content"
    # Test changing pseuds on a work
    When I go to testuser's works page
      And I follow "Edit"
      And I select "testy" from "work_author_attributes_ids_"
      And I unselect "testuser" from "work_author_attributes_ids_"
      And I press "Post without preview"
    Then I should see "testy"
      And I should not see "testuser,"
