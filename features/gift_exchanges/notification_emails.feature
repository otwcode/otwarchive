Feature: Gift Exchange Notification Emails
  Make sure that gift exchange notification emails are formatted properly

  Scenario: Assignment notification emails should be sent to two owners in their respective locales
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

    Given I have added a co-moderator "mod2" to collection "Holiday Swap"
      And a locale with translated emails
      And the user "mod1" enables translated emails
    When I close signups for "Holiday Swap"
      And I have generated matches for "Holiday Swap"
      And I have sent assignments for "Holiday Swap"

    Then 4 emails should be delivered
      And "mod1" should receive 1 email
      And the email to "mod1" should be translated
      And "mod2" should receive 1 email
      And the email to "mod2" should be non-translated
      And "participant1" should receive 1 email
      And "participant2" should receive 1 email

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
