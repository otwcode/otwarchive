@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to delete my account

Scenario: delete a user with no works
  When I am logged in as "downthemall" with password "password"
    And I go to downthemall's user page
    And I follow "Profile"
  Then I should see "Delete My Account"
  When I follow "Delete My Account"
  Then I should not see "Do you want to orphan or delete your works?"
    And I should see "You have successfully deleted your account."
    And I should not see "Log Out"
    And I should see "Log In"
  When I fill in "User name" with "downthemall"
    And I fill in "Password" with "password"
    And I press "Log In"
  Then I should get the error message for wrong username or password

Scenario: delete a user and delete the works
  When I am logged in as "otheruser" with password "secret"
    And all emails have been delivered
    And I post the work "To be deleted"
    And I go to the works page
  Then I should see "To be deleted"
  When I go to otheruser's user page
    And I follow "Profile"
  Then I should see "Delete My Account"
  When I follow "Delete My Account"
  Then I should see "What do you want to do with your works?"
  When I choose "Delete completely"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And 1 email should be delivered
    And I should not see "Log Out"
    And I should see "Log In"
  When I fill in "User name" with "otheruser"
    And I fill in "Password" with "password"
    And I press "Log In"
  Then I should get the error message for wrong username or password
  When I go to the works page
  Then I should not see "To be deleted"

Scenario: delete a user and orphan the works
  Given I have an orphan account
  When I am logged in as "orphaner" with password "secret"
    And all emails have been delivered
    And I post the work "To be orphaned"
    And I go to the works page
  Then I should see "To be orphaned"
    And I should see "orphaner" within "#main"
  When I go to orphaner's user page
    And I follow "Profile"
  Then I should see "Delete My Account"
  When I follow "Delete My Account"
  Then I should see "What do you want to do with your works?"
  When I choose "Change my pseud to 'orphan' and attach to the orphan account"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And 0 emails should be delivered
    And I should not see "Log Out"
    And I should see "Log In"
  When I fill in "User name" with "otheruser"
    And I fill in "Password" with "password"
    And I press "Log In"
  Then I should get the error message for wrong username or password
  When I go to the works page
  Then I should see "To be orphaned"
    And I should see "orphan_account"
    And I should not see "orphaner"

Scenario: delete a user with a collection
  Given I have an orphan account
  When I am logged in as "moderator" with password "password"
    And all emails have been delivered
    And I create the collection "fake"
    And I go to the collections page
  Then I should see "fake"
    And I should see "moderator" within "#main"
  When I go to moderator's user page
    And I follow "Profile"
  Then I should see "Delete My Account"
  When I follow "Delete My Account"
  Then I should see "You have 1 collection(s) under the following pseuds: moderator."
  When I choose "Change my pseud to 'orphan' and attach to the orphan account"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And 0 emails should be delivered
    And I should not see "Log Out"
    And I should see "Log In"
  When I go to the collections page
  Then I should see "fake"
    # TODO: And a caching bug is fixed...
    # And I should see "orphan_account"
    # And I should not see "moderator"
