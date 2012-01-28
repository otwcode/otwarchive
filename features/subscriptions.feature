Feature: Subscriptions
  In order to follow an author I like
  As a reader
  I want to subscribe to them

  Background:
  Given the following activated users exist
    | login          | password   | email           |
    | first_user     | password   | first_user@foo.com |
    | second_user    | password   | second_user@foo.com |
  And all emails have been delivered

  Scenario: subscribe to an author
  
  When I am logged in as "second_user" with password "something"
    And I go to first_user's user page
    And I press "Subscribe"
  Then I should see "You are now following first_user"
  When I go to my subscriptions page
  Then I should see "Unsubscribe from first_user"
  When I log out
    And I am logged in as "first_user" with password "something"
    And I post the work "Awesome Story"
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "first_user"
    And the email should contain "Awesome Story"
  When all emails have been delivered
    And I post the work "Yet Another Awesome Story" without preview
  Then 1 email should be delivered to "second_user@foo.com"
  When I follow "Add Chapter"
    And I fill in "content" with "la la la la la la la la la la la"
    And all emails have been delivered
    And I press "Preview"
  Then 0 emails should be delivered
  When I press "Post Chapter"
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "posted a new chapter"
  
  Scenario: unsubscribe from an author
  
  When I am logged in as "second_user" with password "something"
    And I go to first_user's user page
    And I press "Subscribe"
    And I follow "Unsubscribe"
  Then I should see "successfully unsubscribed"
  When I log out
    And I am logged in as "first_user" with password "something"
    And I post the work "Awesome Story 2: The Sequel"
  Then 0 emails should be delivered
    
  Scenario: subscribe button on profile page
  
  When I am logged in as "second_user" with password "something"
    And I go to first_user's profile page
    And I press "Subscribe"
  Then I should see "You are now following first_user"
    And I should not see "Fandoms"
  When I follow "Unsubscribe"
  Then I should see "successfully unsubscribed"
  
  Scenario: subscribe to individual work
  
  When I am logged in as "first_user"
    And I post the work "Awesome Story"
    And I log out
  When I am logged in as "second_user"
    And I go to first_user's user page
    And I follow "Awesome Story"
    And I press "Subscribe"
  Then I should see "You are now following Awesome Story"
  When I log out
    And I am logged in as "first_user"
    And I go to first_user's user page
    And I follow "Awesome Story"
  When I follow "Add Chapter"
    And I fill in "content" with "la la la la la la la la la la la"
    And all emails have been delivered
    And I press "Preview"
  Then 0 emails should be delivered
  When I press "Post Chapter"
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "posted a new chapter"
    
