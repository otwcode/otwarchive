@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to change my username

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
    Then I should see "Your password was incorrect"

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
