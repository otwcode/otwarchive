@users
Feature: First login help banner

  Scenario: Turn off first login help banner having viewed it

  Given the following activated user exists
    | login         | password   |
    | newname       | password   |
    And I am logged in as "newname" with password "password"
  Then I should see "Hi, newname!"
    And I should see "Log out"
  When I am on newname's user page
  Then I should see "It looks like you've just logged into the archive for the first time"
  When I follow "Learn some tips and tricks."
  Then I should see "Here are some tips to help you get started."
    And I should see "To log in, locate and fill in the log in link"
  When I follow "Dismiss this message permanently"
  Then I should not see "It looks like you've just logged into the archive for the first time"
  When I am logged out
    And I am logged in as "newname" with password "password"
  Then I should not see "It looks like you've just logged into the archive for the first time"
  When I am on newname's user page
  Then I should not see "It looks like you've just logged into the archive for the first time"
  
  Scenario: Turn off first login help banner without having viewed it

  Given the following activated user exists
    | login         | password   |
    | newname2      | password   |
    And I am logged in as "newname2" with password "password"
  Then I should see "Hi, newname2!"
    And I should see "Log out"
  When I am on newname2's user page
  Then I should see "It looks like you've just logged into the archive for the first time"
  When I follow "Dismiss this message permanently"
  Then I should not see "It looks like you've just logged into the archive for the first time"
  When I am logged out
    And I am logged in as "newname2" with password "password"
  Then I should not see "It looks like you've just logged into the archive for the first time"
  When I am on newname2's user page
  Then I should not see "It looks like you've just logged into the archive for the first time"
