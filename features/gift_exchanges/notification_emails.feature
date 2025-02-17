Feature: Gift Exchange Notification Emails
  Make sure that gift exchange notification emails are formatted properly

  Scenario: Assignment sent notification emails should be sent to two owners in their respective locales when assignments are generated
    Given I have created the tagless gift exchange "Holiday Swap"
      And I open signups for "Holiday Swap"
    
    When I am logged in as "participant1"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I am logged in as "participant2"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I have added a co-moderator "mod2" to collection "Holiday Swap"
      And a locale with translated emails
      And the user "mod1" enables translated emails
      And I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"

    Then 4 emails should be delivered
      And "mod1" should receive 1 email
      And the email to "mod1" should be translated
      And the email should contain "You have received a message about your collection"
      And "mod2" should receive 1 email
      And the email to "mod2" should be non-translated
      And the email should contain "You have received a message about your collection"
      And "participant1" should receive 1 email
      And "participant2" should receive 1 email

  Scenario: If collection email is set, use the collection email instead of moderator emails
    Given I have created the tagless gift exchange "Holiday Swap"
      And I open signups for "Holiday Swap"
      And I am logged in as "participant1"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
      And I am logged in as "participant2"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
      And I have added a co-moderator "mod2" to collection "Holiday Swap"
      And I go to "Holiday Swap" collection's page
      And I follow "Collection Settings"
      And I fill in "Collection email" with "test@archiveofourown.org"
      And I press "Update"
      And I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"
    Then 3 emails should be delivered
      And 1 email should be delivered to test@archiveofourown.org
      And the email should contain "You have received a message about your collection"

  Scenario: Default notification emails should be sent to two owners in their respective locales when a user defaults on an assignment
    
    Given everyone has their assignments for "Holiday Swap"
      And I have added a co-moderator "mod2" to collection "Holiday Swap"
      And a locale with translated emails
      And the user "mod1" enables translated emails

    When I am logged in as "myname1"
      And I go to my assignments page
      And I follow "Default"
    Then I should see "We have notified the collection maintainers that you had to default on your assignment."
      And 7 emails should be delivered
      And "mod1" should receive 2 emails
      And the last email to "mod1" should be translated
      And the last email should contain "defaulted on their assignment"
      And "mod2" should receive 1 email
      And the email to "mod2" should be non-translated
      And the email should contain "defaulted on their assignment"

  Scenario: Assignment notifications with linebreaks.
    Given I have created the tagless gift exchange "Holiday Swap"
      And I open signups for "Holiday Swap"
      And I create an assignment notification message with linebreaks for "Holiday Swap"

    When I am logged in as "participant1"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I am logged in as "participant2"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"

    Then 3 emails should be delivered
      And "mod1" should receive 1 email
      And "participant1" should receive 1 email
      And "participant2" should receive 1 email
      And the notification message to "participant1" should contain linebreaks
      And the notification message to "participant2" should contain linebreaks

  Scenario: Assignment notifications with ampersands should escape them.
    Given I have created the tagless gift exchange "Holiday Swap"
      And I open signups for "Holiday Swap"
      And I create an assignment notification message with an ampersand for "Holiday Swap"

    When I am logged in as "participant1"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I am logged in as "participant2"
      And I start signing up for "Holiday Swap"
      And I press "Submit"
    Then I should see "Sign-up was successfully created."

    When I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"

    Then 3 emails should be delivered
      And "mod1" should receive 1 email
      And "participant1" should receive 1 email
      And "participant2" should receive 1 email
      And the notification message to "participant1" should escape the ampersand
      And the notification message to "participant2" should escape the ampersand

  Scenario: Assignment notifications with warning tags work.
    Given I have set up the gift exchange "Dark Fic Exchange"
      And I check "Sign-up open?"
      And I allow warnings in my gift exchange
      And I submit

    When I am logged in as "participant1"
      And I start signing up for "Dark Fic Exchange"
      And I check "No Archive Warnings Apply"
      And I submit
    Then I should see "Sign-up was successfully created."

    When I am logged in as "participant2"
      And I start signing up for "Dark Fic Exchange"
      And I check "No Archive Warnings Apply"
      And I submit
    Then I should see "Sign-up was successfully created."

    When I close signups for "Dark Fic Exchange"
      And I have generated matches for "Dark Fic Exchange"
      And I have sent assignments for "Dark Fic Exchange"

    Then "participant1" should receive 1 email
      And the notification message to "participant1" should contain the no archive warnings tag

  Scenario: Assignment notifications should be sent to participants in their respective locales
    Given the gift exchange "Holiday Swap" is ready for matching
      And a locale with translated emails
      And the user "myname1" enables translated emails
    When I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"
    Then "myname1" should receive 1 email
      And the email should have "Your assignment!" in the subject
      And the email to "myname1" should be translated
    And "myname2" should receive 1 email
      And the email should have "Your assignment!" in the subject
      And the email to "myname2" should be non-translated
