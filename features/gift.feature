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
  Then I should see "Preview Work"
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
    
    