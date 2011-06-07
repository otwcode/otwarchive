Feature: Subscriptions
  In order to follow an author I like
  As a reader
  I want to subscribe to them

  Background:
  Given the following activated users exist
    | login          | password    | email           |
    | myname1        | something   | myname1@foo.com |
    | myname2        | something   | myname2@foo.com |
    | myname3        | something   | myname3@foo.com |
  And all emails have been delivered

  Scenario: subscribe to an author

  When I am logged in as "myname2" with password "something"
    And I go to myname1's user page
    # '
    And I press "Subscribe"
  Then I should see "You are now following myname1"
  When I go to my subscriptions page
  Then I should see "Unsubscribe from myname1"
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I post the work "Awesome Story"
  Then 1 email should be delivered to "myname2@foo.com"
    And the email should contain "myname1"
    And the email should contain "Awesome Story"
  When all emails have been delivered
    And I post the work "Yet Another Awesome Story" without preview
  Then 1 email should be delivered to "myname2@foo.com"
  When I follow "Add Chapter"
    And I fill in "content" with "la la la la la la la la la la la"
    And all emails have been delivered
    And I press "Preview"
  Then 0 emails should be delivered
  When I press "Post Chapter"
  Then 1 email should be delivered to "myname2@foo.com"
    And the email should contain "posted a new chapter"

  Scenario: unsubscribe from an author

  When I am logged in as "myname2" with password "something"
    And I go to myname1's user page
    # '
    And I press "Subscribe"
    And I follow "Unsubscribe"
  Then I should see "successfully unsubscribed"
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I post the work "Awesome Story 2: The Sequel"
  Then 0 emails should be delivered
    
   
