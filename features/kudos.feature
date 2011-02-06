Feature: Leave kudos
  In order to show appreciation
  As a reader
  I want to leave kudos

  Background:
  Given the following activated users exist
    | login          | password    | email           |
    | myname1        | something   | myname1@foo.com |
    | myname2        | something   | myname2@foo.com |
    | myname3        | something   | myname3@foo.com |
    And I am logged in as "myname1" with password "something"
    And I post the work "Awesome Story"
    And I follow "Log out"


  Scenario: post kudos

  When I am logged in as "myname2" with password "something"
    And all emails have been delivered
    And I view the work "Awesome Story"
  Then I should not see "left kudos on this work!"
  When I press "Leave Kudos ♥"
  Then I should see "myname2 left kudos on this work!"
    And 1 email should be delivered to "myname1@foo.com"
    And the email should contain "myname2"
    And the email should contain "left kudos"
    And all emails have been delivered
  When I press "Leave Kudos ♥"
  Then I should see "You have already left kudos here. :)"
    And I should not see "myname2 and myname2 left kudos on this work!"
  When I follow "Log out"
    And I press "Leave Kudos ♥"
  Then 1 email should be delivered to "myname1@foo.com"
    And the email should contain "A guest"
    And the email should contain "left kudos"
  Then I should see "myname2 as well as a guest left kudos on this work!"
  When I press "Leave Kudos ♥"
  Then I should see "You have already left kudos here. :)"
  When I am logged in as "myname3" with password "something"
    And I view the work "Awesome Story"
    And I press "Leave Kudos ♥"
  Then I should see "myname3 and myname2 as well as a guest left kudos on this work!"
  When I am logged in as "myname1" with password "something"
    And I view the work "Awesome Story"
    Then I should not see "Leave Kudos ♥"
 # Then I should see "You can't leave kudos for yourself. :)"

  Scenario: kudos on a multi-chapter work
  When I am logged in as "myname1" with password "something"
    And I post the chaptered work "Epic Saga"
    And I follow "Add Chapter"
    And I fill in "content" with "third chapter is a draft"
    And I press "Preview"
    And I follow "Log out"
  When I am logged in as "myname3" with password "something"
    And I view the work "Epic Saga"
    And I press "Leave Kudos ♥"
  Then I should see "myname3 left kudos on this work!"
  When I follow "Next Chapter"
  Then I should see "myname3 left kudos on this work!"
  When I follow "View Entire Work"
  Then I should see "myname3 left kudos on this work!"
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I view the work "Epic Saga"
  Then I should see "myname3 left kudos on this work!"
  When I follow "Next Chapter"
  Then I should see "myname3 left kudos on this work!"
  When I follow "Next Chapter"
  Then I should not see "myname3 left kudos on this work!"
  When I follow "View Entire Work"
  Then I should see "myname3 left kudos on this work!"
  
  Scenario: deleting pseud and user after creating kudos should orphan them

  When I am logged in as "myname3" with password "something"
    And "myname3" creates the default pseud "foobar"
    And I view the work "Awesome Story"
    And I press "Leave Kudos ♥"
  Then I should see "foobar (myname3) left kudos on this work!"
  When "myname3" creates the default pseud "barfoo"
    And I am on myname3's pseuds page
    #'
    And I follow "delete_foobar"
    And I view the work "Awesome Story"
  Then I should see "barfoo (myname3) left kudos on this work!"
  When "myname3" deletes their account
    And I view the work "Awesome Story"
    And "issue 2198" is fixed
  # Then I should see "a guest left kudos on this work!"


