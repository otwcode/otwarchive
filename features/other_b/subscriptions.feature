  Feature: Subscriptions
  In order to follow an author I like
  As a reader
  I want to subscribe to them

  Background:
  Given the following activated users exist
    | login          | password   | email           |
    | first_user     | password   | first_user@foo.com |
    | second_user    | password   | second_user@foo.com |
    | third_user     | password   | third_user@foo.com |
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
  When I go to the subscriptions page for "second_user"
    And I press "Unsubscribe from first_user"
  Then I should see "successfully unsubscribed"
    And I should be on the subscriptions page for "second_user"

  Scenario: subscribe button on profile page

  When I am logged in as "second_user"
    And I go to first_user's profile page
    And I press "Subscribe"
  Then I should see "You are now following first_user. If you'd like to stop receiving email updates, you can unsubscribe from your Subscriptions page."
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

  Scenario: receive notification of a titled chapter

  When "second_user" subscribes to work "Cake Story"
    And I am logged in as "wip_author"
    And I view the work "Cake Story"
    And I follow "Add Chapter"
    And I fill in "Chapter Title" with "ICE CREAM CAKE"
    And I fill in "content" with "meltiiiinnngg"
    And I press "Post"
    And subscription notifications are sent
  Then 1 email should be delivered to "second_user@foo.com"
    And the email should contain "wip_author"
    And the email should contain "posted"
    And the email should not contain "Chapter ICE CREAM CAKE"
    And the email should contain "Chapter 2: ICE CREAM CAKE"

  Scenario: subscribe to series

  When "second_user" subscribes to series "Awesome Series"
    And I am logged in as "series_author"
    And I set up the draft "Second Work"
    And I check "series-options-show"
    And I select "Awesome Series" from "work_series_attributes_id"
    And I press "Post"
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

  Scenario: different types of subscriptions are listed separately on a user's subscription page

  When I am logged in as "second_user"
    And "second_user" subscribes to author "third_user"
    And "second_user" subscribes to work "Awesome Story"
    And "second_user" subscribes to series "Awesome Series"
  When I go to the subscriptions page for "second_user"
  Then I should see "My Subscriptions"
    And I should see "Awesome Series (Series)"
    And I should see a link "series_author"
    And I should see "third_user"
    And I should see "Awesome Story (Work)"
    And I should see a link "wip_author"
  When I follow "Series Subscriptions"
  Then I should see "My Series Subscriptions"
    And I should see "Awesome Series"
    And I should not see "(Series)"
    And I should not see "third_user"
    And I should not see "Awesome Story"
  When I follow "User Subscriptions"
  Then I should see "My User Subscriptions"
    And I should see "third_user"
    And I should not see "Awesome Series"
    And I should not see "Awesome Story"
  When I follow "Work Subscriptions"
  Then I should see "My Work Subscriptions"
    And I should see "Awesome Story"
    And I should not see "(Work)"
    And I should not see "Awesome Series"
    And I should not see "third_user"

  Scenario: Subscribe to a multi-chapter work should redirect you back to the chapter you were viewing

  When I am logged in as "first_user"
    And I post the work "Multi Chapter Work"
    And a chapter is added to "Multi Chapter Work"
  When I am logged in as "second_user"
    And I view the work "Multi Chapter Work"
    And I view the 2nd chapter
  When I press "Subscribe"
  Then the page title should include "Chapter 2"

  # There are tests in collections/collection_anonymity.feature that ensure
  # a creator's subscribers are not notified when the creator posts a new
  # anonymous work.
  Scenario: When a chapter is added to an anonymous work, subscription emails
  are sent to users who have subscribed to the work, but not to users who have
  subscribed to the creator.

  Given the anonymous collection "anonymous_collection"
    And I am logged in as "creator"
    And I post the work "Multi Chapter Work" to the collection "anonymous_collection"
    And "author_subscriber" subscribes to author "creator"
    And "work_subscriber" subscribes to work "Multi Chapter Work"
  When a chapter is added to "Multi Chapter Work"
    And subscription notifications are sent
  Then "author_subscriber" should not be emailed
    But "work_subscriber" should be emailed
    And the email should have "Anonymous posted Chapter 2 of Multi Chapter Work" in the subject
    And the email should contain "Multi Chapter Work"
    And the email should contain "Anonymous"
    And the email should not contain "creator"

  Scenario: When a chapter is added to an anonymous work in an anonymous series,
  subscription emails are sent to users who have subscribed to the work or
  series, but not to users who have subscribed to the creator.
 
  Given the anonymous collection "anonymous_collection"
    And I am logged in as "creator"
    And I post the work "Multi Chapter Work" to the collection "anonymous_collection" as part of a series "Multi Work Series"
    And "author_subscriber" subscribes to author "creator"
    And "work_subscriber" subscribes to work "Multi Chapter Work"
    And "series_subscriber" subscribes to series "Multi Work Series"
  When a chapter is added to "Multi Chapter Work"
    And subscription notifications are sent
  Then "author_subscriber" should not be emailed
    But "work_subscriber" should be emailed
    And the email should have "Anonymous posted Chapter 2 of Multi Chapter Work" in the subject
    And the email should contain "Multi Chapter Work"
    And the email should contain "Anonymous"
    And the email should not contain "creator"
    And "series_subscriber" should be emailed
    And the email should have "Anonymous posted Chapter 2 of Multi Chapter Work in the Multi Work Series series" in the subject
    And the email should contain "Multi Chapter Work"
    And the email should contain "Anonymous"
    And the email should not contain "creator"

  Scenario: When a new work is added to an anonymous series, subscription emails
  are sent to users who are subscribed to the series, but not users who have 
  subscribed to the creator.
 
  Given the anonymous collection "anonymous_collection"
    And I am logged in as "creator"
    And I post the work "Multi Chapter Work" to the collection "anonymous_collection" as part of a series "Multi Work Series"
    And "author_subscriber" subscribes to author "creator"
    And "series_subscriber" subscribes to series "Multi Work Series"
  When I am logged in as "creator"
    And I post the work "Second Work" to the collection "anonymous_collection" as part of a series "Multi Work Series"
    And subscription notifications are sent
  Then "author_subscriber" should not be emailed
    But "series_subscriber" should be emailed
    And the email should have "Anonymous posted Second Work in the Multi Work Series series" in the subject
    And the email should contain "Multi Work Series"
    And the email should contain "Second Work"
    And the email should contain "Anonymous"
    And the email should not contain "creator"

    Scenario: When new chapter for a hidden work is posted, no subscription notifications are sent

      Given I am logged in as "violator"
        And I post the work "TOS Violation" as part of a series "Dont Be So Series"
        And "author_subscriber" subscribes to author "violator"
        And "work_subscriber" subscribes to work "TOS Violation"
        And "series_subscriber" subscribes to series "Dont Be So Series"
      When I am logged in as a "policy_and_abuse" admin
        And I hide the work "TOS Violation"
        And a chapter is added to "TOS Violation"
        And subscription notifications are sent
      Then "author_subscriber" should not be emailed
        And "work_subscriber" should not be emailed
        And "series_subscriber" should not be emailed
      When I am logged in as a "policy_and_abuse" admin
        And I unhide the work "TOS Violation"
        And subscription notifications are sent
      Then "author_subscriber" should not be emailed
        And "work_subscriber" should not be emailed
        And "series_subscriber" should not be emailed
      When a chapter is added to "TOS Violation"
        And subscription notifications are sent
      Then "author_subscriber" should be emailed
        And "work_subscriber" should be emailed
        And "series_subscriber" should be emailed

    Scenario: When a hidden work is unrevealed, no subscription notifications are sent

      Given I am logged in as "violator"
        And I post the work "TOS Violation" as part of a series "Dont Be So Series"
        And "author_subscriber" subscribes to author "violator"
        And "work_subscriber" subscribes to work "TOS Violation"
        And "series_subscriber" subscribes to series "Dont Be So Series"
        And I have the hidden collection "Secret"
        And I am logged in as "violator"
        And I edit the work "TOS Violation" to be in the collection "Secret"
        And I am logged in as a "policy_and_abuse" admin
        And I hide the work "TOS Violation"
      When I am logged in as "moderator"
        And I go to "Secret" collection's page
        And I follow "Collection Settings"
        And I uncheck "This collection is unrevealed"
        And I press "Update"
        And subscription notifications are sent
      Then "author_subscriber" should not be emailed
        And "work_subscriber" should not be emailed
        And "series_subscriber" should not be emailed
      When I am logged in as a "policy_and_abuse" admin
        And I unhide the work "TOS Violation"
        And subscription notifications are sent
      Then "author_subscriber" should not be emailed
        And "work_subscriber" should not be emailed
        And "series_subscriber" should not be emailed

    Scenario: Translated subscription email

      Given a locale with translated emails
        And the user "anna" exists and is activated
        And the user "anna" enables translated emails
        And "anna" subscribes to author "creator"
        And "arthur" subscribes to author "creator"
      When I am logged in as "creator"
        And I post the work "great thing"
        And subscription notifications are sent
      Then 1 email should be delivered to "anna"
        And the email should have "creator posted great thing" in the subject
        And the email to "anna" should be translated
        And the email to "anna" should contain "Fändom"
        And the email to "anna" should not contain "Fandom"
        And 1 email should be delivered to "arthur"
        And the email should have "creator posted great thing" in the subject
        And the email to "arthur" should be non-translated
        And the email to "arthur" should not contain "Fändom"
        And the email to "arthur" should contain "Fandom"

  Scenario: subscribe to an individual work with an the & and < and > characters in the title

  Given the work "I am &lt;strong&gt;er Than Yesterday &amp; Other Lies" by "testuser2"
  When I am logged in as "subscriber" with password "password"
    And I view the work "I am &lt;strong&gt;er Than Yesterday &amp; Other Lies"
  When I press "Subscribe"
  Then I should see "You are now following I am <strong>er Than Yesterday & Other Lies. If you'd like to stop receiving email updates, you can unsubscribe from your Subscriptions page."
  When I am logged in as "testuser2" with password "testuser2"
    And a chapter is added to "I am &lt;strong&gt;er Than Yesterday &amp; Other Lies"
  When I view the work "I am &lt;strong&gt;er Than Yesterday &amp; Other Lies"
  When subscription notifications are sent
  Then 1 email should be delivered to "subscriber"
  When "The problem with ampersands and angle brackets in email bodies and subjects" is fixed
    #And the email should have "I am <strong>er Than Yesterday & Other Lies" in the subject
    #And the email should contain "I am <strong>er Than Yesterday & Other Lies"
  When I am logged in as "subscriber" with password "password"
    And I go to the subscriptions page for "subscriber"
    And I press "Unsubscribe from I am <strong>er Than Yesterday & Other Lies"
  Then I should see "You have successfully unsubscribed from I am <strong>er Than Yesterday & Other Lies"

Scenario: delete all subscriptions

  When I am logged in as "second_user"
    And "second_user" subscribes to author "third_user"
    And "second_user" subscribes to work "Awesome Story"
    And "second_user" subscribes to series "Awesome Series"
  When I go to the subscriptions page for "second_user"
  Then I should see "My Subscriptions"
    And I should see "Awesome Series (Series)"
    And I should see "third_user"
    And I should see "Awesome Story (Work)"
  When I follow "Delete All Subscriptions"
  Then I should see "Are you sure you want to delete"
  When I press "Yes, Delete All Subscriptions"
  Then I should see "My Subscriptions"
    And I should see "Your subscriptions have been deleted"
    And I should not see "Awesome Series (Series)"
    And I should not see "third_user"
    And I should not see "Awesome Story (Work)"

Scenario: delete all subscriptions of a specific type

  When I am logged in as "second_user"
    And "second_user" subscribes to author "third_user"
    And "second_user" subscribes to work "Awesome Story"
    And "second_user" subscribes to series "Awesome Series"
  When I go to the subscriptions page for "second_user"
  Then I should see "My Subscriptions"
    And I should see "Awesome Series (Series)"
    And I should see "third_user"
    And I should see "Awesome Story (Work)"
  When I follow "Work Subscriptions"
  Then I should see "My Work Subscriptions"
  When I follow "Delete All Work Subscriptions"
  Then I should see "Delete All Work Subscriptions"
    And I should see "Are you sure you want to delete"
  When I press "Yes, Delete All Work Subscriptions"
  Then I should see "Your subscriptions have been deleted"
  When I go to the subscriptions page for "second_user"
  Then I should see "Awesome Series (Series)"
    And I should see "third_user"
    But I should not see "Awesome Story (Work)"

Scenario: subscriptions are not deleted without confirmation

  When I am logged in as "second_user"
    And "second_user" subscribes to work "Awesome Story"
  When I go to the subscriptions page for "second_user"
  Then I should see "My Subscriptions"
    And I should see "Awesome Story (Work)"
  When I follow "Delete All Subscriptions"
  Then I should see "Are you sure you want to delete"
  When I go to the subscriptions page for "second_user"
  Then I should see "My Subscriptions"
    And I should see "Awesome Story (Work)"
