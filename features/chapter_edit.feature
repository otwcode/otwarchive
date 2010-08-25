@work
Feature: Edit chapters
  In order to have an work full of chapters
  As a humble user
  I want to add and remove chapters

  Scenario: Add chapters to an existing work, delete chapters, edit chapters, post chapters in the wrong order, use rearrange page

  Given the following activated user exists
    | login         | password   |
    | epicauthor    | password   |
    And basic tags
  When I go to epicauthor's user page
    Then I should see "There are no works"
  When I am logged in as "epicauthor" with password "password"
  
  # create a basic single-chapter work
  When I follow "Post New"
  Then I should see "Post New Work"
  When I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "New Fandom"
    And I fill in "Work Title" with "New Epic Work"
    And I fill in "Work text" with "Well, maybe not so epic."
    And I press "Preview"
  Then I should see "Draft was successfully created"
    And I should see "1/1"
  When I press "Post"
  Then I should not see "Chapter 1"
    And I should see "Well, maybe not so epic"
    
  # add chapters to a single-chapter work
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "5"
    And I fill in "chapter_wip_length" with "100"
    And I fill in "content" with "entering chapter five out of order"
    And I press "Preview"
  Then I should see "This is a preview of what this chapter will look like"
  When I press "Post"
    Then I should see "2/100"
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "3"
    And I fill in "chapter_wip_length" with "50"
    And I fill in "content" with "entering chapter three out of order"
    And I press "Preview"
  Then I should see "Chapter 3"
  When I press "Post"
  Then I should see "3/50"
  
  # add chapters in the wrong order
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "17"
    And I fill in "chapter_wip_length" with "17"
    And I fill in "content" with "entering last chapter out of order"
    And I press "Preview"
  Then I should see "Chapter 17"
  When I press "Post"
    And I should see "4/17"
    
  # delete a chapter
  When I follow "Edit"
    And I follow "5"
    And I press "Preview"
    And I follow "Delete Chapter"
  Then I should see "The chapter was successfully deleted."
    And I should see "3/17"
    
  # fill in the missing chapter
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "2"
    And I fill in "content" with "finally entering second chapter"
    And I press "Preview"
  When I press "Post"
    Then I should see "4/17"
  
  # edit an existing chapter
  When I follow "Edit"
    And I follow "16" 
    And I fill in "chapter_position" with "4"
    And I fill in "chapter_wip_length" with "4"
    And I press "Preview"
  Then I should see "Chapter 4"
  When I press "Update"
  Then I should see "Chapter was successfully updated"
    And I should see "Chapter 4"
    And I should see "4/4"
  When I follow "Edit"
    And I follow "Manage Chapters"
  Then I should see "Drag chapters to change their order."
  
  # view chapters in the right order
  When I am logged out
    And I go to epicauthor's works page
    And I follow "New Epic Work"
    And I follow "View Entire Work"
  Then I should see "Chapter 1"
    And I should see "Well, maybe not so epic." within "#chapter-1"
    And I should see "Chapter 2"
    And I should see "finally entering second chapter" within "#chapter-2"
    And I should see "Chapter 3"
    And I should see "entering chapter three out of order" within "#chapter-3"
    And I should see "Chapter 4"
    And I should see "entering last chapter out of order" within "#chapter-4"
    And I should not see "entering chapter five out of order"
  When I follow "View chapter by chapter"
    And I follow "Chapter Index"
  Then I should see "Chapter Index for New Epic Work by epicauthor"
    And I should see "Chapter 1"
    And I should see "Chapter 2"
    And I should see "Chapter 3"
    And I should see "Chapter 4"
    
  # move chapters around using rearrange page
  When I am logged out
    And I am logged in as "epicauthor" with password "password"
    And I view the work "New Epic Work"
    And I follow "Edit"
    And I follow "Manage Chapters"
  Then I should see "Drag chapters to change their order."
  Then show me the page
  When I fill in "chapters_1" with "4"
    And I fill in "chapters_2" with "3"
    And I fill in "chapters_3" with "2"
    And I fill in "chapters_4" with "1"
  And I press "Update Positions"
  Then I should see "Chapter orders have been successfully updated."
  When I am logged out
    And I go to epicauthor's works page
    And I follow "New Epic Work"
    And I follow "View Entire Work"
  Then I should see "Chapter 1"
    And I should see "Well, maybe not so epic." within "#chapter-4"
    And I should see "Chapter 2"
    And I should see "finally entering second chapter" within "#chapter-3"
    And I should see "Chapter 3"
    And I should see "entering chapter three out of order" within "#chapter-2"
    And I should see "Chapter 4"
    And I should see "entering last chapter out of order" within "#chapter-1"
  
