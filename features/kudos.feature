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
    And I view the work "Awesome Story"
  Then I should not see "Kudos were left"
  When I press "Leave Kudos ♥"
  Then I should see "Kudos were left by myname2!"
  When I press "Leave Kudos ♥"
  Then I should see "You have already left kudos here. :)"
    And I should not see "Kudos were left by myname2 and myname2!"
  When I follow "Log out"
    And I press "Leave Kudos ♥"
  Then I should see "Kudos were left by myname2 as well as a guest!"
  When I press "Leave Kudos ♥"
  Then I should see "Kudos were left by myname2 as well as 2 guests!"
  When I am logged in as "myname3" with password "something"
    And I view the work "Awesome Story"
    And I press "Leave Kudos ♥"
  Then I should see "Kudos were left by myname3 and myname2 as well as 2 guests!"
  
  
  Scenario: deleting pseud and user after creating kudos should orphan them
  
  When I am logged in as "myname3" with password "something"
    And "myname3" creates the default pseud "foobar"
    And I view the work "Awesome Story"
    And I press "Leave Kudos ♥"
  Then I should see "Kudos were left by foobar (myname3)!"
  When "myname3" creates the default pseud "barfoo"
    And I am on myname3's pseuds page
    #'
    And I follow "delete_foobar"
    And I view the work "Awesome Story"
  Then I should see "Kudos were left by barfoo (myname3)!"
  When "myname3" deletes their account
    And I view the work "Awesome Story"
  Then I should see "Kudos were left by a guest!"
  
  