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
      And all indexing jobs have been run
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
      # line below fails with perform_caching: true because of issue 3461
      # And I should see "Additional Tags: new tag"
      And I should see "first chapter content"
    When I press "Update"
    Then I should see "Work was successfully updated."
      And I should see "Additional Tags: new tag"
      And I should see "Words:3"
    When all indexing jobs have been run
      And I go to testuser's works page
    Then I should see "First work"
      And I should see "first fandom"
      And I should see "new tag"
    When I edit the work "First work"
      And I follow "Add Chapter"
      And I fill in "content" with "second chapter content"
      And I press "Preview"
    Then I should see "This is a draft chapter in a posted work. It will be kept unless the work is deleted."
      And I should see "second chapter content"
    When I press "Post"
    Then I should see "Chapter was successfully posted."
      And I should not see "first chapter content"
      And I should see "second chapter content"
      And I should see "Words:6"
    When I edit the work "First work"
    Then I should not see "chapter content"
    When I follow "1"
      And I fill in "content" with "first chapter new content"
      And I press "Preview"
    Then I should see "first chapter new content"
    When I press "Update"
    Then I should see "Chapter was successfully updated."
      And I should see "first chapter new content"
      And I should not see "second chapter content"
      And I should see "Words:7"
    When I edit the work "First Work"
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
      And I press "Post Without Preview"
    Then I should see "testy"
      And I should not see "testuser,"

  Scenario: Editing a work in a moderated collection
    # TODO: Find a way to appove works without using this hack method I have here
    Given the following activated users exist
      | login          | password   |
      | Scott          | password   |
      And I have a moderated collection "Digital Hoarders 2013" with name "digital_hoarders_2013"
      And I am logged out
    When I am logged in as "Scott" with password "password"
      And I post the work "Murder in Milan" in the collection "Digital Hoarders 2013"
    Then I should see "You have submitted your work to the moderated collection 'Digital Hoarders 2013'. It will not become a part of the collection until it has been approved by a moderator."
      And I am logged out
      And I am logged in as "moderator"
      And I go to "Digital Hoarders 2013" collection's page
      And I follow "Collection Settings"
      And I uncheck "This collection is moderated"
      And I press "Update"
    Then I should see "Collection was successfully updated"
      And I am logged out
    When I am logged in as "Scott"
      And I post the work "Murder by Numbers" in the collection "Digital Hoarders 2013"
    Then I should see "Work was successfully posted"
      And I am logged out
    When I am logged in as "moderator"
      And I go to "Digital Hoarders 2013" collection's page
      And I follow "Collection Settings"
      And I check "This collection is moderated"
      And I press "Update"
    Then I should see "Collection was successfully updated"
      And I am logged out
    When I am logged in as "Scott"
      And I edit the work "Murder by Numbers"
      And I press "Post Without Preview"
      And I should see "Work was successfully updated"
    Then I should not see "You have submitted your work to the moderated collection 'Digital Hoarders 2013'. It will not become a part of the collection until it has been approved by a moderator."
      
  Scenario: Previewing edits to a posted work should not refer to the work as a draft
    Given I am logged in as "editor"
      And I post the work "Load of Typos"
    When I edit the work "Load of Typos"
      And I press "Preview"
    Then I should not see "draft"

  Scenario: You can add a co-author to an already-posted work
    Given I am logged in as "leadauthor"
      And I post the work "Dialogue"
    When I add the co-author "coauthor" to the work "Dialogue"
    Then I should see "Work was successfully updated"
      And I should see "coauthor, leadauthor" within ".byline"

  Scenario: You can remove yourself as coauthor from a work
    Given the following activated users exist
        | login          |
        | coolperson     |
        | ex_friend      |
      And I coauthored the work "Shared" as "coolperson" with "ex_friend"
      And I am logged in as "coolperson"
    When I view the work "Shared"
    Then I should see "coolperson, ex_friend" within ".byline"
    When I edit the work "Shared"
      And I wait 1 second
      And I follow "Remove Me As Author"
    Then I should see "You have been removed as an author from the work"
      And "ex_friend" should be the creator on the work "Shared"
      And "coolperson" should not be a creator on the work "Shared"

  Scenario: User applies a coauthor's work skin to their work
    Given the following activated users with private work skins
        | login       |
        | lead_author |
        | coauthor    |
        | random_user |
      And I coauthored the work "Shared" as "lead_author" with "coauthor"
      And I am logged in as "lead_author"
    When I edit the work "Shared"
    Then I should see "Lead Author's Work Skin" within "#work_work_skin_id"
      And I should see "Coauthor's Work Skin" within "#work_work_skin_id"
      And I should not see "Random User's Work Skin" within "#work_work_skin_id"
    When I select "Coauthor's Work Skin" from "Select Work Skin"
      And I press "Post Without Preview"
    Then I should see "Work was successfully updated"

  Scenario: A work cannot be edited to remove its fandom
    Given basic tags
      And I am logged in as a random user
      And I post the work "Work 1" with fandom "testing"
    When I edit the work "Work 1"
      And I fill in "Fandoms" with ""
      And I press "Post Without Preview"
    Then I should see "Sorry! We couldn't save this work because:Please add all required tags. Fandom is missing."

  Scenario: User can cancel editing a work
    Given I am logged in as a random user
      And I post the work "Work 1" with fandom "testing"
      And I edit the work "Work 1"
      And I fill in "Fandoms" with ""
      And I press "Cancel"
    When I view the work "Work 1"
      Then I should see "Fandom: testing"

  Scenario: When editing a work, the title field should not escape HTML
    Given I have a work "What a title! :< :& :>"
      And I go to the works page
      And I follow "What a title! :< :& :>"
      And I follow "Edit"
    Then I should see "What a title! :< :& :>" in the "Work Title" input
