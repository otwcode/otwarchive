@comments
Feature: Read official comments
  In order to tell genuine official accounts from impersonators
  As a user
  I'd like to see the "official" sign

Scenario: View official comments in admin post
  Given I have posted an admin post
  Given the user "official_account" exists and has the role "official"
    And I am logged in as "official_account"
    And I follow "News"
    And I follow "Default Admin Post"
    And I fill in "Comment" with "Official information!"
    And I press "Comment"
  Then I should see "(Official)"
  When I am logged in as "normal_user"
    And I follow "Default Admin Post"
    And I follow "Comments (1)"
  Then I should see "(Official)"

Scenario: View fake official comments in admin post
  Given I have posted an admin post
  Given I am logged in as "fake_official_account"
    And I follow "News"
    And I follow "Default Admin Post"
    And I fill in "Comment" with "Official information!"
    And I press "Comment"
  Then I should not see "(Official)"
  When I am logged in as "normal_user"
    And I follow "Default Admin Post"
    And I follow "Comments (1)"
  Then I should not see "(Official)"

Scenario: View official comments in dashboard, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3"
  Given the user "official_account" exists and has the role "official"
    And I am logged in as "official_account"
    And I go to the works page 
    And I follow "My very meta work about AO3"
    And I post a comment ":)))))))"
  Then I should see "(Official)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should see "(Official)"
    And I follow "My Inbox"
  Then I should see "(Official)"
    And I go to the works page 
    And I follow "My very meta work about AO3"
    And I follow "Comments (1)"
  Then I should see "(Official)"

Scenario: View fake official comments in dashboard, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3"
  Given I am logged in as "fake_official_account"
    And I go to the works page 
    And I follow "My very meta work about AO3"
    And I post a comment ":)))))))"
  Then I should not see "(Official)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should not see "(Official)"
    And I follow "My Inbox"
  Then I should not see "(Official)"
    And I go to the works page 
    And I follow "My very meta work about AO3"
    And I follow "Comments (1)"
  Then I should not see "(Official)"