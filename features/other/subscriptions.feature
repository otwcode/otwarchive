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
  
  When "second_user" subscribes to author "first_user"
    And I am logged in as "first_user"
    And I post the work "Awesome Story"
  # make sure no emails go out until notifications are sent
  Then 0 emails should be delivered
  When subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "first_user"
    And the email should contain "Awesome"
  When all emails have been delivered
    And I post the work "Yet Another Awesome Story" without preview
    And subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
  When all emails have been delivered
    And a draft chapter is added to "Yet Another Awesome Story"
  Then 0 emails should be delivered
  When I post the draft chapter
  Then 0 emails should be delivered
  When subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    # This feels hackish to me (scott s), but I'm going with it for now. I'll investigate reworking our email steps for multipart emails once all our gems are up to date.
    And the email should contain "first_user"
    And the email should contain "posted"
    And the email should contain "Chapter 2"
  
  Scenario: unsubscribe from an author
  
  When I am logged in as "second_user"
    And I go to first_user's user page
    And I press "Subscribe"
    And I press "Unsubscribe"
  Then I should see "successfully unsubscribed"
    And I should be on first_user's user page
  When I log out
    And I am logged in as "first_user"
    And I post the work "Awesome Story 2: The Sequel"
    And subscription notifications are sent
  Then 0 emails should be delivered

  Scenario: unsubscribe from the subscriptions page

  When I am logged in as "second_user"
    And I go to first_user's user page
    And I press "Subscribe"
  When I go to my subscriptions page
    And I press "Unsubscribe from first_user"
  Then I should see "successfully unsubscribed"
    And I should be on my subscriptions page

  Scenario: subscribe button on profile page
  
  When I am logged in as "second_user"
    And I go to first_user's profile page
    And I press "Subscribe"
  Then I should see "You are now following first_user"
  When I press "Unsubscribe"
  Then I should see "successfully unsubscribed"

  Scenario: subscribe to individual work
  
  When "second_user" subscribes to work "Awesome Story"
    And a draft chapter is added to "Awesome Story"
  Then 0 emails should be delivered
  When I post the draft chapter
  Then 0 emails should be delivered
  When subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "wip_author"
    And the email should contain "posted"
    And the email should contain "Chapter 2"
    
  Scenario: subscribe to series
  
  When "second_user" subscribes to series "Awesome Series"
    And I am logged in as "series_author"
    And I set up the draft "Second Work"
    And I check "series-options-show"
    And I select "Awesome Series" from "work_series_attributes_id"
    And I press "Post Without Preview"
  Then 0 emails should be delivered
  When subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "posted a"
    And the email should contain "new work"

  Scenario: batched subscription notifications
  
  When "second_user" subscribes to author "first_user"
    And I am logged in as "first_user"
    And I post the work "The First Awesome Story"
  # make sure no emails go out until notifications are sent
  Then 0 emails should be delivered
  When I post the work "Another Awesome Story"
    And I post the work "A Third Awesome Story"
    And I post the work "A FOURTH Awesome Story"
  Then 0 emails should be delivered
  When subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "The First"
    And the email should contain "Another"
    And the email should contain "A Third"
    And the email should contain "A FOURTH"
    
