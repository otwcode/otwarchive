@users
Feature: Delete pseud.
  In order to tidy some mess
  As a humble user
  I want to delete a pseud

  Scenario: Delete pseud, have option to move works, delete works, or orphan works. Test if those choices work.
  Given I have loaded the fixtures
  When I am logged in as "sad_user_with_no_pseuds" with password "testuser"
    And I am on sad_user_with_no_pseuds's pseuds page
  Then I should not see "Delete"
  When I am logged out
  And I am logged in as "testuser" with password "testuser"
    And I am on testuser's pseuds page
  When I follow "delete_tester_pseud"
  Then I should see "Delete these bookmarks"
  When I choose "Delete these bookmarks"
    And I submit
  Then I should see "The pseud was successfully deleted."
  When I am on testuser's pseuds page
    Then I should not see "tester_pseud"
    And I follow "delete_testy"
    And I choose "Transfer these bookmarks to the default pseud"
    And I submit
  Then I should see "The pseud was successfully deleted."
  When I am on testuser's pseuds page
    And I follow "testymctesty"
  Then I should see "fourth"
    And I should not see "fifth work"
              
     
    
      
