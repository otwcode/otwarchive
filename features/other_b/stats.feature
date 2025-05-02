@stats
Feature: User statistics
  In order to know more about my works
  As a user
  The statistics page needs to show me information about my works

  Scenario: A user with no works should see a message
  Given I am logged in as "lurker"
  When I go to lurker's stats page
  Then I should see "You currently have no works posted to the Archive. If you add some, you'll find information on this page about hits, kudos, comments, and bookmarks of your works."
    And I should see "Users can also see how many subscribers they have, but not the names of their subscribers or identifying information about other users who have viewed or downloaded their works."
  
  Scenario: Show only posted works on stats page
  
  Given I am logged in as "NUMB3RSfan"
    And I post the work "Don Solves Crime"
    And I post the work "Don Solves More Crime"
    And I set up the draft "Charlie Helps"
  When I am logged in as "reader"
    And I view the work "Don Solves Crime"
    And I am logged in as "NUMB3RSfan"
    And I go to NUMB3RSfan's stats page
  Then "Don Solves Crime" should appear before "Don Solves More Crime"
    And I should not see "Charlie Helps"
  When I follow "Date"
  Then "Don Solves More Crime" should appear before "Don Solves Crime"
  When I follow "Date"
  Then "Don Solves Crime" should appear before "Don Solves More Crime"

  Scenario: Calculate word counts from chapter publication date
  
  Given I am logged in as "statistician"
    And I set up the draft "Multiyear Fic"
    And I fill in "content" with "Three words long."
    And I set the publication date to 3 March 2023
    And I press "Post"
    And I follow "Add Chapter"
    And I fill in "content" with "Oh look, four words!"
    And I set the publication date to 4 April 2024
    And I press "Post"
  When I go to statistician's stats page
  Then I should see a link "2023"
    And I should see a link "2024"
    And I should see "Multiyear Fic (7 words)"
    And I should see "Word Count: 7"
  When I follow "2023"
  Then I should see "Multiyear Fic (3 words)"
    And I should see "Word Count: 3"
  When I follow "2024"
  Then I should see "Multiyear Fic (4 words)"
    And I should see "Word Count: 4"

  Scenario: Sort works by chapter publication within year

  Given I am logged in as "statistician"
    And I set up the draft "New-Year Celebration"
    And I set the publication date to 1 January 2023
    And I press "Post"
    And I follow "Add Chapter"
    And I set the publication date to 2 January 2024
    And I press "Post"
    And I set up the draft "Year-End Party"
    And I set the publication date to 9 December 2023
    And I press "Post"
    And I set up the draft "Midyear Madness"
    And I set the publication date to 2 July 2023
    And I press "Post"
  When I go to statistician's stats page
    And I follow "2023"
    And I follow "Flat View"
    And I follow "Date"
    Then "New-Year Celebration" should appear before "Midyear Madness"
    Then "Midyear Madness" should appear before "Year-End Party"
