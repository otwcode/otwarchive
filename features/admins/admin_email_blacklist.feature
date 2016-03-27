@admin
Feature: Admin email blacklist
  In order to prevent the use of certain email addresses in guest comments
  As an an admin
  I want to be able to manage a blacklist of email addresses
  
Scenario: Add email address to blacklist
  Given I am logged in as an admin
  Then I should see "Blacklist"
  When I follow "Blacklist"
  Then I should see "Find blacklisted email addresses"
    And I should see "Add To Blacklist"
    And I should see "Add email address to blacklist for guest comments"
    And I should see "Email"
  When I fill in "Email" with "foo@bar.com"
    And I press "Add"
  Then I should see "Email address foo@bar.com added to blacklist"
    And the address "foo@bar.com" should be in the blacklist

Scenario: Remove email address from blacklist
  Given I am logged in as an admin
    And I have blacklisted the address "foo@bar.com"
  When I follow "Blacklist"
    And I fill in "Search for email" with "bar"
  Then I should see "foo@bar.com"
  When I follow "Remove"
  Then I should see "Email address foo@bar.com removed from blacklist"
    And the address "foo@bar.com" should not be in the blacklist
    
Scenario: Blacklisted email addresses should not be usable in guest comments
  Given I am logged in as an admin
    And I have blacklisted the address "foo@bar.com"
    And I am logged in as "author"
    And I have posted the work "New Work"
  When I am logged out
    And I view the work "New Work"
    And I fill in "Name" with "Someone"
    And I fill in "Email" with "foo@bar.com"
    And I fill in "Comment" with "I loved this!"
    And I press "Comment"
  Then I should see "The owner of this email address has asked not to receive email from us. That means it can't be used in guest comments. Please check the address to make sure it's yours to use"
    And I should not see "Comments (1)"
  When I fill in "Email" with "someone@bar.com"
    And I press "Comment"
  Then I should see "Comments (1)"
