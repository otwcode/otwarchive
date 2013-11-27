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
      And all search indexes are updated
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
      And all search indexes are updated
    When I go to testuser's works page
    Then I should see "First work"
      And I should see "first fandom"
      And I should see "new tag"
    When I edit the work "First work"
      And I follow "Add Chapter"
      And I fill in "content" with "second chapter content"
      And I press "Preview"
    Then I should see "This is a draft showing what this chapter will look like when it's posted to the Archive."
      And I should see "second chapter content"
    When I press "Post"
    Then I should see "Chapter was successfully posted."
      And I should not see "first chapter content"
      And I should see "second chapter content"
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
    Then I should see "Your work will only show up in the moderated collection you have submitted it to once it is approved by a moderator."
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
    Then I should not see "Your work will only show up in the moderated collection you have submitted it to once it is approved by a moderator."      
      
  Scenario: Editing a work you created today should not bump its revised-at date
      When "Issue 2542" is fixed    
# Given I am logged in as "testuser" with password "testuser"
#      And I post the work "Don't Bump Me"
#      And I post the work "This One Stays On Top"
#      And I edit the work "Don't Bump Me"
#      And I press "Post Without Preview"
#    When I go to the works page
#    Then "This One Stays On Top" should appear before "Don't Bump Me"
#    When I edit the work "Don't Bump Me"
#      And I press "Preview"
#      And I press "Update"
#      And I go to the works page
#    Then "This One Stays On Top" should appear before "Don't Bump Me"
