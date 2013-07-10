@works
Feature: Edit chapters
  In order to have an work full of chapters
  As a humble user
  I want to add and remove chapters

  Scenario: Add chapters to an existing work, delete chapters, edit chapters, post chapters in the wrong order, use rearrange page, create draft chapter

  Given the following activated user exists
    | login         | password   |
    | epicauthor    | password   |
    And basic tags
  When I go to epicauthor's user page
    Then I should see "There are no works"
  When I am logged in as "epicauthor" with password "password"
  
  # create a basic single-chapter work
  When I follow "New Work"
  Then I should see "Post New Work"
  When I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "New Fandom"
    And I fill in "Work Title" with "New Epic Work"
    And I fill in "content" with "Well, maybe not so epic."
    And I press "Preview"
  Then I should see "Draft was successfully created"
    And I should see "1/1"
  When I press "Post"
  Then I should not see "Chapter 1"
    And I should see "Well, maybe not so epic"
    And I should see "Words:5"
    
  # add chapters to a single-chapter work
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "2"
    And I fill in "chapter_wip_length" with "100"
    And I fill in "content" with "original chapter two"
    And "Issue 3306" is fixed
    # All the commented out bits in the following examples need to be changed
    # back once Issue 3306 has bee fixed.
    #And I press "Preview"
  #Then I should see "This is a draft showing what this chapter will look like when it's posted to the Archive."
  #When I press "Post"
  When I press "Post Without Preview"
    Then I should see "2/100"
    And I should see "Words:8"
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "3"
    And I fill in "chapter_wip_length" with "50"
    And I fill in "content" with "entering chapter three"
    #And I press "Preview"
    And I press "Post Without Preview"
  Then I should see "Chapter 3"
  #When I press "Post"
  Then I should see "3/50"
    And I should see "Words:11"
  
  # add chapters in the wrong order
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "17"
    And I fill in "chapter_wip_length" with "17"
    And I fill in "content" with "entering fourth chapter out of order"
    #And I press "Preview"
    And I press "Post Without Preview"
  Then I should see "Chapter 4"
  #When I press "Post"
    And I should see "4/17"
    And I should see "Words:17"
    
  # delete a chapter
  When I follow "Edit"
    And I follow "2"
    And I follow "Delete Chapter"
  Then I should see "The chapter was successfully deleted."
    And I should see "3/17"
    And I should see "Words:14"
    
  # fill in the missing chapter
  When I follow "Add Chapter"
    And I fill in "chapter_position" with "2"
    And I fill in "content" with "entering second chapter out of order"
    #And I press "Preview"
  #When I press "Post"
  And I press "Post Without Preview"
  Then I should see "4/17"
    And I should see "Words:20"
  
  # edit an existing chapter
  When I follow "Edit"
    And I follow "3" 
    And I fill in "chapter_position" with "4"
    And I fill in "chapter_wip_length" with "4"
    And I fill in "content" with "last chapter"
    #And I press "Preview"
    And I press "Update Without Preview"
  Then I should see "Chapter 4"
  #When I press "Update"
  Then I should see "Chapter was successfully updated"
    #And I should see "Chapter 4"
    And I should see "4/4"
    And I should see "Words:19"
  When I follow "Edit"
    And I follow "Manage Chapters"
  Then I should see "Drag chapters to change their order."
  
  # view chapters in the right order
  When I am logged out
    And I go to epicauthor's works page
    And I follow "New Epic Work"
    And I follow "Entire Work"
  Then I should see "Chapter 1"
    And I should see "Well, maybe not so epic." within "#chapter-1"
    And I should see "Chapter 2"
    And I should see "entering second chapter out of order" within "#chapter-2"
    And I should see "Chapter 3"
    And I should see "entering fourth chapter out of order" within "#chapter-3"
    And I should see "Chapter 4"
    And I should see "last chapter" within "#chapter-4"
    And I should not see "original chapter two"
  When I follow "View chapter by chapter"
    And I follow "Chapter Index"
  Then I should see "Chapter Index for New Epic Work by epicauthor"
    And I should see "Chapter 1"
    And I should see "Chapter 2"
    And I should see "Chapter 3"
    And I should see "Chapter 4"
    
  # move chapters around using rearrange page
  When I am logged in as "epicauthor" with password "password"
    And I view the work "New Epic Work"
    And I follow "Edit"
    And I follow "Manage Chapters"
  Then I should see "Drag chapters to change their order."
  When I fill in "chapters_1" with "4"
    And I fill in "chapters_2" with "3"
    And I fill in "chapters_3" with "2"
    And I fill in "chapters_4" with "1"
  And I press "Update Positions"
  Then I should see "Chapter order has been successfully updated."
  When I am logged out
    And I go to epicauthor's works page
    And I follow "New Epic Work"
    And I follow "Entire Work"
  Then I should see "Chapter 1"
    And I should see "Well, maybe not so epic." within "#chapter-4"
    And I should see "Chapter 2"
    And I should see "second chapter" within "#chapter-3"
    And I should see "Chapter 3"
    And I should see "fourth chapter" within "#chapter-2"
    And I should see "Chapter 4"
    And I should see "last chapter" within "#chapter-1"

  # create a draft chapter and post it
  When I am logged in as "epicauthor" with password "password"
    And I view the work "New Epic Work"
    And I follow "Add Chapter"
    And I fill in "Chapter title" with "My title"
    And I fill in "content" with "some more epic context"
    And I press "Preview"
    And I view the work "New Epic Work"
    And I follow "Edit"
  Then I should see "5 (Draft)"
  When I view the work "New Epic Work"
    Then I should see "4/5"
  When I select "5. My title" from "selected_id"
    And I press "Go"
    Then I should see "This chapter is a draft and hasn't been posted yet!"
  When I press "Post"
    Then I should see "5/5"
  When I follow "Edit"
    Then I should not see "Draft"
    And I should not see "draft"
  When I view the work "New Epic Work"
    And I select "5. My title" from "selected_id"
    And I press "Go"
    Then I should not see "Draft"
    And I should not see "draft"

  # create a draft chapter, preview it, edit it and then post it without preview
  When I am logged in as "epicauthor" with password "password"
    And I view the work "New Epic Work"
    And I follow "Add Chapter"
    And I fill in "Chapter title" with "6(66) The Number of the Beast"
    And I fill in "content" with "Even more awesomely epic context"
    And I press "Preview"
  Then I should see "This is a draft showing what this chapter will look like when it's posted to the Archive."
  When I press "Edit"
    And I fill in "content" with "Even more awesomely epic context. Plus bonus epicness"
    And I press "Post Without Preview"
    Then I should see "Chapter was successfully updated."
    And I should not see "This chapter is a draft and hasn't been posted yet!"

  # create a draft chapter, preview it, edit it, preview it again and then post it
  When I am logged in as "epicauthor" with password "password"
    And I view the work "New Epic Work"
    And I follow "Add Chapter"
    And I fill in "Chapter title" with "6(66) The Number of the Beast"
    And I fill in "content" with "Even more awesomely epic context"
    And I press "Preview"
  Then I should see "This is a draft showing what this chapter will look like when it's posted to the Archive."
  When I press "Edit"
    And I fill in "content" with "Even more awesomely epic context. Plus bonus epicness"
    And I press "Preview"
  Then I should see "Even more awesomely epic context. Plus bonus epicness"
  When I press "Post"
    Then I should see "Chapter was successfully updated."
    And I should not see "This chapter is a draft and hasn't been posted yet!"


  Scenario: view chapter title info pop up
    
  Given the following activated user exists
    | login         | password   |
    | epicauthor    | password   |
    And basic tags
  When I am logged in as "epicauthor"
    And I go to epicauthor's user page
    And I follow "New Work"
    And I select "Not Rated" from "Rating"
    And I check "No Archive Warnings Apply"
    And I fill in "Fandoms" with "New Fandom"
    And I fill in "Work Title" with "New Epic Work"
    And I fill in "content" with "Well, maybe not so epic."
    And I press "Post"
    And I follow "Add Chapter"
    And I follow "Chapter title"
  Then I should see "You can add a chapter title"
