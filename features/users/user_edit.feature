@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my account details

  Scenario: The user should not be able to change username without a password
    Given I am logged in as "testuser" with password "password"
    When I visit the change username page for testuser
    And I fill in "New username" with "anothertestuser"
      And I press "Change Username"
    Then I should see "Your password was incorrect"

  Scenario: The user should not be able to change their username with an incorrect password
    Given I am logged in as "testuser" with password "password"
    When I visit the change username page for testuser
      And I fill in "New username" with "anothertestuser"
      And I fill in "Password" with "wrongpwd"
      And I press "Change Username"
    Then I should see "Your password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form. If you are still having trouble, contact Support for help."

  Scenario: The user should not be able to change their username to their current username
    Given I am logged in as "testuser" with password "password"
    When I visit the change username page for testuser
      And I fill in "New username" with "testuser"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should see "Your new username must be different from your current username"

  Scenario: The user should be able to change only the capitalization of their username
    Given I am logged in as "testy" with password "password"
    When I visit the change username page for testy
      And I fill in "New username" with "teSty"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, teSty!"

  Scenario: The user should not be able to change their username to another user's name
    Given I have no users
      And the following activated user exists
      | login     | password |
      | otheruser | secret   |
      And I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New username" with "otheruser"
      And I fill in "Password" with "password"
    When I press "Change"
      Then I should see "Username has already been taken"

  Scenario: The user should not be able to change their username to another user's name even if the capitalization is different
    Given I have no users
      And the following activated user exists
      | login     | password |
      | otheruser | secret   |
      And I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New username" with "OtherUser"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should see "Username has already been taken"

  Scenario: The user should be able to change their username if username and password are valid
    Given I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New username" with "DownThemAll"
      And I fill in "Password" with "password"
      And I press "Change"
    Then I should get confirmation that I changed my username
      And I should see "Hi, DownThemAll!"

  Scenario: The user should receive an email notification after they change their username
    Given I am logged in as "before" with password "password"
      And a locale with translated emails
      And the user "before" enables translated emails
      And it is currently 2025-01-01 00:00 AM
    When I change my username to "after"
    Then "after" should receive 1 email
      And the email should contain "account .*before.* has been changed to .*after"
      And the email should contain "usernames can only be changed once every 7 days"
      And the email should contain "You will be able to change your username again on Wed, 08 Jan 2025 00:00:00 \+0000"
      And the email to "after" should be translated

  Scenario: The user should be able to change their username to a similar version with underscores
    Given I am logged in as "downthemall" with password "password"
    When I visit the change username page for downthemall
      And I fill in "New username" with "Down_Them_All"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, Down_Them_All!"

  Scenario: Changing my username with one pseud changes that pseud
    Given I have no users
      And I am logged in as "oldusername" with password "password"
    When I visit the change username page for oldusername
      And I fill in "New username" with "newusername"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, newusername"
    When I go to newusername's pseuds page
      Then I should not see "oldusername"
    When I follow "Edit"
    Then I should see "You cannot change the pseud that matches your username"
    Then the "pseud_is_default" checkbox should be checked and disabled

  Scenario: Changing only the capitalization of my username with one pseud changes that pseud's capitalization
    Given I have no users
      And I am logged in as "uppercrust" with password "password"
    When I visit the change username page for uppercrust
      And I fill in "New username" with "Uppercrust"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, Uppercrust"
    When I go to Uppercrust's pseuds page
      Then I should not see "uppercrust"
    When I follow "Edit"
    Then I should see "You cannot change the pseud that matches your username"
    Then the "pseud_is_default" checkbox should be checked and disabled

  Scenario: Changing my username with two pseuds, one same as new, doesn't change old
    Given I have no users
      And the following activated user exists
      | login         | password | id |
      | oldusername   | secret   | 1  |
      And a pseud exists with name: "newusername", user_id: 1
      And I am logged in as "oldusername" with password "secret"
    When I visit the change username page for oldusername
      And I fill in "New username" with "newusername"
      And I fill in "Password" with "secret"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, newusername"
    When I follow "Pseuds (2)"
      Then I should see "Edit oldusername"
      And I should see "Edit newusername"

  Scenario: Changing username updates search results (bug AO3-3468)
    Given I have no users
      And I am logged in as "oldusername" with password "password"
      And I post a work "Epic story"
      And I wait 1 second
    When I visit the change username page for oldusername
      And I fill in "New username" with "newusername"
      And I fill in "Password" with "password"
      And I press "Change Username"
      And all indexing jobs have been run
    Then I should get confirmation that I changed my username
    When I am on the works page
    Then I should see "newusername"
      And I should see "Epic story"
      And I should not see "oldusername"
    When I search for works containing "oldusername"
    Then I should see "No results found"
      And I should not see "Epic story"
    When I search for works containing "newusername"
    Then I should see "Epic story"

  Scenario: Comments reflect username changes immediately
    Given the work "Interesting"
      And I am logged in as "before" with password "password"
      And "before" creates the pseud "mine"
    When I set up the comment "Wow!" on the work "Interesting"
      And I select "mine" from "comment[pseud_id]"
      And I press "Comment"
      And I view the work "Interesting" with comments
    Then I should see "mine (before)"
    When it is currently 1 second from now
      And I visit the change username page for before
      And I fill in "New username" with "after"
      And I fill in "Password" with "password"
      And I press "Change Username"
      And I view the work "Interesting" with comments
    Then I should see "after" within ".comment h4.byline"
      And I should not see "mine (before)"

  Scenario: Collections reflect username changes of the owner after the cache expires
    When I am logged in as "before" with password "password"
      And I create the collection "My Collection Thing"
      And I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "before" within "#main"
    When I change my username to "after"
      And I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "before" within "#main"
    When the collection blurb cache has expired
      And I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "after" within "#main"
      And I should not see "before" within "#main"

  Scenario: Collections reflect username changes of moderators after the cache expires
    Given I am logged in as "mod1"
      And I create the collection "My Collection Thing"
      And I have added a co-moderator "before" to collection "My Collection Thing"
    When I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "before" within "#main"
    When I am logged in as "before" with password "password"
      And I change my username to "after"
      And I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "before" within "#main"
    When the collection blurb cache has expired
      And I go to the collections page
    Then I should see "My Collection Thing"
      And I should see "after" within "#main"
      And I should not see "before" within "#main"

  Scenario: Changing username updates series blurbs
    Given I have no users
      And I am logged in as "oldusername" with password "password"
      And I add the work "Great Work" to series "Best Series"
    When I go to the dashboard page for user "oldusername" with pseud "oldusername"
      And I follow "Series"
    Then I should see "Best Series by oldusername"
    When I visit the change username page for oldusername
      And I fill in "New username" with "newusername"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then I should get confirmation that I changed my username
      And I should see "Hi, newusername"
    When I follow "Series"
    Then I should see "Best Series by newusername"

  Scenario: Changing username updates chapter bylines
    Given the work "Title" by "pikachu" with chapter two co-authored with "before"
      And I am logged in as "before" with password "password"
      And I post a chapter for the work "Title"
    When I view the work "Title"
      And I view the 3rd chapter
    Then I should see "Chapter by before"
    When I visit the change username page for before
      And I fill in "New username" with "after"
      And I fill in "Password" with "password"
      And it is currently 1 second from now
      And I press "Change Username"
    Then I should see "Your username has been successfully updated."
    When I view the work "Title"
      And I view the 3rd chapter
    Then I should see "Chapter by after"

    Scenario: Changing the username from a forbidden name to non-forbidden
      Given I have no users
        And the following activated user exists
          | login     | password |
          | forbidden | secret   |
        And the username "forbidden" is on the forbidden list
      When I am logged in as "forbidden" with password "secret"
        And I visit the change username page for forbidden
        And I fill in "New username" with "notforbidden"
        And I fill in "Password" with "secret"
        And I press "Change Username"
      Then I should get confirmation that I changed my username
        And I should see "Hi, notforbidden"

  Scenario: Tag wrangling supervisors are emailed about tag wrangler username changes
    Given the user "before" exists and is activated
      And I am logged in as "before" with password "password"
      And all emails have been delivered
      And I visit the change username page for before
      And I fill in "New username" with "after"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then 0 email should be delivered to "tagwranglers-personnel@example.org"
    When the user "wrangler_before" exists and has the role "tag_wrangler"
      And I am logged in as "wrangler_before" with password "password"
      And all emails have been delivered
      And I visit the change username page for wrangler_before
      And I fill in "New username" with "wrangler_after"
      And I fill in "Password" with "password"
      And I press "Change Username"
    Then 1 email should be delivered to "tagwranglers-personnel@example.org"
      And the email should contain "The wrangler"
      And the email should contain "wrangler_before"
      And the email should contain "has changed their name"
      And the email should contain "wrangler_after"

  Scenario: Bookmarker's bookmark blurbs reflect username changes immediately
    Given the work "Interesting"
      And I am logged in as "before"
      And I bookmark the work "Interesting"
      And I go to before's bookmarks page
    Then I should see "Bookmarked by before"

    When it is currently 1 second from now
      And I change my username to "after"
      And I go to after's bookmarks page
    Then I should see "Bookmarked by after"
      And I should not see "Bookmarked by before"

  Scenario: Changing email address shows a confirmation page and sends a confirmation email
    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
    When it is currently 2020-04-10 13:37
      And the email address change confirmation period is set to 4 days
      And I visit the change email page for editname
      And I fill in "New email" with "valid2@archiveofourown.org"
      And I fill in "Enter new email again" with "valid2@archiveofourown.org"
      And I fill in "Password" with "password"
      And I press "Confirm New Email"
    Then I should see "Are you sure you want to change your email address to valid2@archiveofourown.org?"
      And I should see "If you don't confirm your request within 4 days"
      And 0 emails should be delivered
    When I press "Yes, Change Email"
    Then I should see "You have requested to change your email address to valid2@archiveofourown.org."
      And I should see "If you don't confirm your request by Tue, 14 Apr 2020"
      And I should see "bar@ao3.org"
      And 1 email should be delivered to "bar@ao3.org"
      And the email should contain "Someone has made a request to change the email address associated with your AO3 account."
      And the email should contain "valid2@archiveofourown.org"
      And 1 email should be delivered to "valid2@archiveofourown.org"
      And the email should contain "request to change the email address associated with the AO3 account"
      And the email should contain "editname"

    When I am a visitor
      And I follow "confirm your email change" in the email
    Then I should see "Sorry, you don't have permission to access the page you were trying to reach. Please log in."
    When I am logged in as "editname"
      And I visit the change email page for editname
    Then I should see "bar@ao3.org"

    When I am logged in as "editname"
      And I follow "confirm your email change" in the email
    Then I should see "Your email has been successfully updated."
      And I should see "valid2@archiveofourown.org"
      But I should not see "bar@ao3.org"
      But I should not see "You have requested to change your email address"
    When I visit the change email page for editname
    Then I should see "valid2@archiveofourown.org"

  Scenario: Changing email address -- canceling in confirmation step
    
    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
    When I visit the change email page for editname
      And I start to change my email to "valid2@archiveofourown.org"
    Then I should see "Are you sure you want to change your email address"
      And 0 emails should be delivered
    When I follow "Cancel"
    Then I should see "Change Email" within "h2.heading"
      And 0 emails should be delivered
      And I should not see "You have requested to change your email address"

  Scenario: Changing email address -- request expires

    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
    When it is currently 2020-04-10 13:37
      And the email address change confirmation period is set to 4 days
      And I visit the change email page for editname
      And I request to change my email to "valid2@archiveofourown.org"
    Then I should see "If you don't confirm your request by Tue, 14 Apr 2020"
      And 1 email should be delivered to "valid2@archiveofourown.org"
      And the email should contain "request to change the email address"
      And I should see "You have requested to change your email address"

    When it is currently 2020-04-15 14:00
      And I visit the change email page for editname
    Then I should not see "You have requested to change your email address"
      And I should see "bar@ao3.org"
      But I should not see "valid2@archiveofourown.org"
    When I follow "confirm your email change" in the email
    Then I should see "This email confirmation link is invalid or expired. Please check your email for the correct link or submit the email change form again."
      And I should see "bar@ao3.org"
      But I should not see "valid2@archiveofourown.org"

  Scenario: Changing email address -- resubmitting form changes target email and expiration date

    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
    When it is currently 2020-04-10 13:37
      And the email address change confirmation period is set to 4 days
      And I visit the change email page for editname
      And I request to change my email to "valid2@archiveofourown.org"
    Then I should see "If you don't confirm your request by Tue, 14 Apr 2020"
      And 1 email should be delivered to "bar@ao3.org"
      And 1 email should be delivered to "valid2@archiveofourown.org"
      And the email should contain "request to change the email address"

    When it is currently 2020-04-12 14:00
      And I request to change my email to "another@archiveofourown.org"
    Then I should see "You have requested to change your email address to another@archiveofourown.org."
      And I should see "If you don't confirm your request by Thu, 16 Apr 2020"
      # The original email gets another notification
      And 2 emails should be delivered to "bar@ao3.org"
      # Old link should be invalid
      And 1 email should be delivered to "valid2@archiveofourown.org"
    When I follow "confirm your email change" in the email
    Then I should see "This email confirmation link is invalid or expired. Please check your email for the correct link or submit the email change form again."
      And I should see "bar@ao3.org"
      And I should see "You have requested to change your email address to another@archiveofourown.org"
      But I should not see "valid2@archiveofourown.org"
      # Newest email gets new link that should work
      And 1 email should be delivered to "another@archiveofourown.org"
      And the email should contain "request to change the email address"
    When I follow "confirm your email change" in the email
    Then I should see "Your email has been successfully updated."
      And I should see "another@archiveofourown.org"
      But I should not see "valid2@archiveofourown.org"
      But I should not see "bar@ao3.org"

  Scenario: Changing email address -- after requesting password reset

    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
    When I am logged out
      And I follow "Forgot password?"
      And I fill in "Email address" with "bar@ao3.org"
      And I press "Reset Password"
    Then 1 email should be delivered to "bar@ao3.org"
    When all emails have been delivered
      And I am logged in as "editname"
      And I follow "My Preferences"
      And I follow "Change Email"
      And I request to change my email to "valid2@archiveofourown.org"
    Then I should see "You have requested to change your email address to valid2@archiveofourown.org."
      And 1 email should be delivered to "bar@ao3.org"
      And 1 email should be delivered to "valid2@archiveofourown.org"
    When I follow "confirm your email change" in the email
    Then I should see "Your email has been successfully updated."
      And I should see "valid2@archiveofourown.org"
      But I should not see "bar@ao3.org"

  Scenario: Changing email address -- translated emails are sent when user enables locale settings

    Given the following activated user exists
    | login    | password   | email  	    |
    | editname | password   | bar@ao3.org |
      And I am logged in as "editname"
      And a locale with translated emails
      And the user "editname" enables translated emails
      And all emails have been delivered
    When I am logged in as "editname"
      And I follow "My Preferences"
      And I follow "Change Email"
      And I request to change my email to "valid2@archiveofourown.org"
    Then the email address "bar@ao3.org" should be emailed
      And the email should have "Email change request" in the subject
      And the email to email address "bar@ao3.org" should be translated
      And 1 email should be delivered to "valid2@archiveofourown.org"
      And the email should have "Confirm your email change" in the subject
      And the email to email address "valid2@archiveofourown.org" should be translated

  Scenario: Change password - mistake in typing old password

    Given I am logged in as "testuser" with password "password"
    When I visit the change password page for testuser
      And I make a mistake typing my old password
    Then I should see "Your old password was incorrect. Please try again or, if you've forgotten your password, log out and reset your password via the link on the login form. If you are still having trouble, contact Support for help."

  Scenario: Change password - mistake in typing new password confirmation

    Given I am logged in as "testuser" with password "password"
    When I visit the change password page for testuser
      And I make a typing mistake confirming my new password
    Then I should see "The passwords you entered do not match. Please try again."

  Scenario: Change password

    Given I am logged in as "testuser" with password "password"
    When it is currently 2025-04-12 17:00 UTC
      And I visit the change password page for testuser
      And I change my password
    Then I should see "Your password has been changed. To protect your account, you have been logged out of all active sessions. Please log in with your new password."
      And 1 email should be delivered to "testuser"
      And the email should have "Your password has been changed" in the subject
      And the email should contain "The password for your AO3 account was changed on Sat, 12 Apr 2025 17:00:\d+ \+0000"
    When I am logged in as a super admin
      And I go to the user administration page for "testuser"
    Then I should see "Password Changed" within "#user_history"
      But I should not see "Password Reset" within "#user_history"
