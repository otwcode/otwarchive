@users
Feature:
  In order to correct mistakes or reflect my evolving personality
  As a registered user
  I should be able to delete my account

Scenario: The Delete My Account link should exist on the Profile page
  Given I am logged in as "downthemall"
  When I go to downthemall's user page
    And I follow "Profile"
  Then I should see "Delete My Account"

Scenario: If I delete a user with no works, the user should be deleted without any prompting
  Given I am logged in as "downthemall"
    And I have no works or comments
  When I try to delete my account as downthemall
  Then I should see "You have successfully deleted your account."
    And a user account should not exist for "downthemall"
    And I should be logged out

Scenario: If a user chooses "Delete Completely" when removing their account,  delete the works associated with that user
  Given I am logged in as "otheruser" with password "secret"
    And all emails have been delivered
    And I post the work "To be deleted"
  When I try to delete my account as otheruser
  Then I should see "What do you want to do with your works?"
    And a user account should exist for "otheruser"
  When I choose "Delete completely"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And a user account should not exist for "otheruser"
    And 1 email should be delivered
    And I should be logged out
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
  When I try to delete my account as orphaner
  Then I should see "What do you want to do with your works?"
  When I choose "Change my pseud to 'orphan' and attach to the orphan account"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And 0 emails should be delivered
    And I should be logged out
    And a user account should not exist for "orphaner"
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
  When I try to delete my account as moderator
  Then I should see "You have 1 collection(s) under the following pseuds: moderator."
  When I choose "Change my pseud to 'orphan' and attach to the orphan account"
    And I press "Save"
  Then I should see "You have successfully deleted your account."
    And 0 emails should be delivered
    And I should be logged out
    And a user account should not exist for "moderator"
  When I go to the collections page
  Then I should see "fake"
    And I should see "orphan_account"
    And I should not see "moderator"
