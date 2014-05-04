@stats
Feature: User statistics
  In order to know more about my works
  As a user
  The statistics page needs to show me information about my works
  
  Scenario: Show only posted works on stats page
  
  Given I am logged in as "NUMB3RSfan"
    And I post the work "Don Solves Crime"
    And I set up the draft "Charlie Helps"
  When I go to my stats page
  Then I should see "Don Solves Crime"
    And I should not see "Charlie Helps"
  
  Scenario: Do not show hit counts on stats page when user has set preference to hide hit counts on their own works
  
  Given I am logged in as "NUMB3RSfan"
    And I set my preferences to hide hit counts on my works
  When I go to my stats page
  Then I should not see "Hits"
  
  Scenario: Do not show hit counts on stats page when user has set preference to hide all hit counts
  
  Given I am logged in as "NUMB3RSfan"
    And I set my preferences to hide all hit counts
  When I go to my stats page
  Then I should not see "Hits"