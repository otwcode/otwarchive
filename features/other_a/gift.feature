Feature: Create Gifts
  In order to make friends and influence people
  As an author
  I want to create works for other people


  Background:
    Given the following activated users exist
      | login      | password    | email            |
      | gifter     | something   | gifter@foo.com   |
      | gifter2    | something   | gifter2@foo.com  |
      | giftee1    | something   | giftee1@foo.com  |
      | giftee2    | something   | giftee2@foo.com  |
      | associate  | something   | associate@foo.com |
      And I am logged in as "gifter" with password "something"
      And I set up the draft "GiftStory1"


  Scenario: Giving a work as a gift when posting directly

    Given I give the work to "giftee1"
    When I press "Post Without Preview"
    Then I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Giving a work as a gift when posting after previewing

    Given I give the work to "giftee1"
      And I press "Preview"
      And I should see "For giftee1"
      And 0 emails should be delivered
    When I press "Post"
    Then I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Edit a draft to add a recipient, then post after previewing

    Given I press "Preview"
      And I press "Edit"
      And I give the work to "giftee1"
      And I press "Preview"
      And 0 emails should be delivered
    When I press "Post"
    Then I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Edit an existing work to add a recipient, then post directly

    Given I press "Post Without Preview"
      And I follow "Edit"
      And I give the work to "giftee1"
    When I press "Post Without Preview"
    Then I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Edit an existing work to add a recipient, then post after previewing

    Given I press "Post Without Preview"
      And I follow "Edit"
      And I give the work to "giftee1"
      And I press "Preview"
      And 0 emails should be delivered
      And I press "Edit"
      And I press "Preview"
      And 0 emails should be delivered
    When I press "Update"
    Then I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Give two gifts to the same recipient

    Given I give the work to "giftee1"
      And I press "Post Without Preview"
      And I set up the draft "GiftStory2"
      And I give the work to "giftee1"
    When I press "Post Without Preview"
      And I follow "giftee1"
    Then I should see "Gifts for giftee1"
      And I should see "GiftStory1"
      And I should see "GiftStory2"


  Scenario: Add another recipient to a posted gift

    Given I give the work to "giftee1"
      And I press "Post Without Preview"
      And I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"
      And all emails have been delivered
      And I follow "Edit"
      And I give the work to "giftee1, giftee2"
    When I press "Post Without Preview"
    Then I should see "For giftee1, giftee2"
      And 0 emails should be delivered to "giftee1@foo.com"
      And "giftee2@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Add another recipient to a draft gift

    Given I give the work to "giftee1"
      And I press "Preview"
      And I should see "For giftee1"
      And 0 emails should be delivered to "giftee1@foo.com"
      And I press "Edit"
      And I give the work to "giftee1, giftee2"
    When I press "Post Without Preview"
    Then I should see "For giftee1, giftee2"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"
      And "giftee2@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Add two recipients, post, then remove one

    Given I give the work to "giftee1, giftee2"
      And I press "Post Without Preview"
      And I should see "For giftee1, giftee2"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"
      And "giftee2@foo.com" should be notified by email about their gift "GiftStory1"
      And all emails have been delivered
      And I follow "Edit"
      And I give the work to "giftee1"
    When I press "Post Without Preview"
    Then I should see "For giftee1"
      And I should not see "giftee2"
      And 0 emails should be delivered to "giftee1@foo.com"
      And 0 emails should be delivered to "giftee2@foo.com"


  Scenario: Add two recipients, preview, then remove one

    Given I give the work to "giftee1, giftee2"
      And I press "Preview"
      And I should see "For giftee1, giftee2"
      And 0 emails should be delivered
      And I press "Edit"
      And I give the work to "giftee1"
    When I press "Post Without Preview"
    Then I should see "For giftee1"
      And I should not see "giftee2"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"
      And 0 emails should be delivered to "giftee2@foo.com"


  Scenario: Edit a posted work to replace one recipient with another

    Given I give the work to "giftee1"
      And I press "Post Without Preview"
      And I should see "For giftee1"
      And "giftee1@foo.com" should be notified by email about their gift "GiftStory1"
      And all emails have been delivered
      And I follow "Edit"
      And I give the work to "giftee2"
    When I press "Post Without Preview"
    Then I should see "For giftee2"
      And I should not see "giftee1"
      And 0 emails should be delivered to "giftee1@foo.com"
      And "giftee2@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: Edit a draft to replace one recipient with another

    Given I give the work to "giftee1"
      And I press "Preview"
      And I should see "For giftee1"
      And 0 emails should be delivered
      And I press "Edit"
      And I give the work to "giftee2"
    When I press "Post Without Preview"
    Then I should see "For giftee2"
      And I should not see "giftee1"
      And 0 emails should be delivered to "giftee1@foo.com"
      And "giftee2@foo.com" should be notified by email about their gift "GiftStory1"


  Scenario: When a user is notified that a co-authored work has been given to them as a gift, the e-mail should link to each author's URL instead of showing escaped HTML

    Given I add the co-author "gifter2"
      And I give the work to "giftee1"
      And I post the work without preview
    Then 1 email should be delivered to "gifter2"
      And the email should contain "You have been listed as a coauthor on the following work"
    Then 1 email should be delivered to "giftee1"
      And the email should link to gifter's user url
      And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/gifter/pseuds/gifter&quot;"
      And the email should link to gifter2's user url
      And the email should not contain "&lt;a href=&quot;http://archiveofourown.org/users/gifter2/pseuds/gifter2&quot;"

  Scenario: A gift work should have an associations list

    Given I give the work to "associate"
    When I press "Post Without Preview"
    Then I should find a list for associations
      And I should see "For associate"
