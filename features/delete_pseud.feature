@wip
Feature: Delete pseud.
  In order to tidy some mess
  As a humble user
  I want to delete a pseud

  Scenario: Delete pseud, have option to move works, delete works, or orphan works. Test if those choices work.

  Given I have loaded the fixtures
  Given I am logged in as "sad_user_with_no_pseuds" with password "test"
    When I visit "My Home"
      And I follow "My Pseuds"
      Then I should not see a "Delete" button
  Given I am logged in as "testuser" with password "test"
    When I visit "My Home"
      And I follow "My Pseuds"
      Then I should see a "Delete" button for pseud "testy"
    When I follow the "Delete" button for pseud "testy"
      And I press "OK"
      Then I should see the bookmarks_action form
        Given I select the radio button "delete_bookmarks"
          And I click "Submit"
          When I click "OK"
          Then I should see "The pseud was successfully deleted."
    When I follow "My Home"
      And I follow "My Pseuds"
      Then I should not see pseud "testy"
    When I follow "My Home"
      And I follow "My Pseuds"
      Then pseud "testuser" should not show a "Delete" button
    When I follow "My Home"
      And I follow "My Pseuds"
      Then pseud "testymctesty" should not show a "Delete" button
    When I follow "My Home"
      And I follow "My Pseuds"
      And I follow the "Delete" button for pseud "testerpseud"
        And I press "OK"
          Then I should see the bookmarks_action form
          When I select the radio button "transfer_bookmarks"
            And I click "Submit"
            And I click "OK"
            Then I should see "The pseud was successfully deleted."
    When I follow "My Home"
      And I follow "My Pseuds"
      And I follow "testymctesty"
      Then I should see fifth_work
              
     
    
      
