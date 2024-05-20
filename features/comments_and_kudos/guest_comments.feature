@comments
Feature: Read guest comments
  In order to tell guest comments from logged-in users' comments
  As a user
  I'd like to see the "guest" sign

Scenario: View guest comments in homepage, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3" with guest comments enabled
    And I am logged out
  When I post a guest comment
  Then I should see "(Guest)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should see "(Guest)"
  When I follow "My Inbox"
  Then I should see "(Guest)"
  When I view the work "My very meta work about AO3" with comments
  Then I should see "(Guest)"

Scenario: View logged-in comments in homepage, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3"
    And I am logged in as "logged_in_user"
  When I post the comment ":)))))))" on the work "My very meta work about AO3"
  Then I should not see "(Guest)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should not see "(Guest)"
  When I follow "My Inbox"
  Then I should not see "(Guest)"
  When I view the work "My very meta work about AO3" with comments
  Then I should not see "(Guest)"
