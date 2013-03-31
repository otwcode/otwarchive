Feature: Create Gifts
  In order to make friends and influence people
  As an author
  I want to create works for other people

  Scenario: Giving a work as a gift
  
  Given the following activated users exist
    | login          | password    | email           |
    | myname1        | something   | myname1@foo.com |
    | myname2        | something   | myname2@foo.com |
    | myname3        | something   | myname3@foo.com |
    And I am logged in as "myname1" with password "something"
    And I set up the draft "GiftStory1"
    And I fill in "work_recipients" with "myname2"
    And I press "Preview"
  Then I should see "Preview"
    And I should see "For myname2"
  
  # make sure the recipient sees it
  When I press "Post"
  Then 1 email should be delivered to "myname2@foo.com"
    And the email should contain "A gift story has been posted for you"
    

  # Give a second gift to same recipient
  Given I set up the draft "GiftStory2"
    And I fill in "work_recipients" with "myname2"
    And I press "Preview"
    And I press "Post"
  Then I should see "GiftStory2"
    And I should see "For myname2"
  When I follow "myname2"
  Then I should see "Gifts for myname2"
    And I should see "GiftStory1"
    And I should see "GiftStory2"

  # Give a third gift using Post Without Preview
  Given I set up the draft "GiftStory3"
    And I fill in "work_recipients" with "myname3"
    And I press "Post Without Preview"
  Then 1 email should be delivered to "myname3@foo.com"
    And all emails have been delivered
    And I follow "Edit"
  # Change the recipient of the gift
  Then I fill in "work_recipients" with "myname2"
    And I press "Preview"
    And 0 emails should be delivered
    And I press "Edit"
    And I press "Preview"
    And 0 emails should be delivered
    And I press "Update"
    And I should see "For myname3, myname2"
  Then 1 email should be delivered to "myname2@foo.com"
    And the email should contain "A gift story has been posted for you"

    
    