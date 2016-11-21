Feature: Subscriptions
  In order to follow a fandom I like
  As a reader
  I want to subscribe to it

  Scenario: Subscribe to a test fandom when there are no works in it

  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/M"
  When I am logged in as "reader"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
   Then I should not see "My Work Title"
     And I should not see "Stargate SG-1"
    
  Scenario: Subscribe to a test fandom when there are works in it
  
  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/F"
  When I am logged in as "reader"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "My Work Title"
    And I should see "Stargate SG-1"

  Scenario: Subscribe to a non-test fandom
  
  When I am logged in as "author"
    And I post a work "My Work Title" with category "Multi"
  When I am logged in as "reader"
    And I view the "Multi" works index
  Then I should not see "RSS Feed"

  Scenario: Changing the title is reflected in the feed.

  When I am logged in as "author"
    And I post a work "A sunny story" with category "F/F"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should see "Stargate SG-1"
  When I edit the work "A sunny story"
    And I fill in "work[title]" with "A dark story"
    And I press "Post Without Preview"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should not see "A sunny story"
    And I should see "A dark story"

  Scenario: Changing the summary is reflected in the feed.

  When I am logged in as "author"
    And I post a work "A sunny story" with category "F/F"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should see "Stargate SG-1"
    And I should not see "A fun story"
  When I edit the work "A sunny story"
    And I fill in "work[summary]" with "A fun story"
    And I press "Post Without Preview"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A fun story"

  Scenario: Changing the username of the author is reflected in the feed.

  When I am logged in as "qpootle5" with password "password"
    And I post a work "A sunny story" with category "F/F"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should see "qpootle5"
  When I visit the change username page for qpootle5
    And I fill in "New user name" with "theblackcat"
    And I fill in "Password" with "password"
  When I press "Change"
  Then I should get confirmation that I changed my username
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should not see "qpootle5"
    And I should see "theblackcat"
  
  Scenario: Adding a co author is reflected in the feed.

  Given a user exists with login: "sam"
  When I am logged in as "qpootle5" with password "password"
    And I post a work "A sunny story" with category "F/F"
    And I view the "F/F" works index
  Then I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should see "qpootle5"
  When I add the co-author "sam" to the work "A sunny story"
  Then I view the "F/F" works index
    And I should see "RSS Feed"
  When I follow "RSS Feed"
  Then I should see "A sunny story"
    And I should see "sam"

  Scenario: Mystery work is not shown in feed
  
  Given basic tags
    And I am logged in as "myname2"
  Given I have a hidden collection "Hidden Treasury" with name "hidden_treasury"
  When I am logged in as "myname1"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "hidden_treasury"
    And I check "F/F"
    And I press "Post Without Preview"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/F"
  When I view the "F/F" works index
  When I follow "RSS Feed"
  Then I should not see "Old Snippet"
    And I should not see "myname1"
    And I should see "author"

  @disable_caching
  Scenario: Author of anonymous work is not shown in feed
    
  Given basic tags
    And I am logged in as "myname2"
  Given I have an anonymous collection "Hidden Treasury" with name "hidden_treasury"
  When I am logged in as "myname1"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "hidden_treasury"
    And I check "F/F"
    And I press "Post Without Preview"
    And all search indexes are updated
  Then I should see "Anonymous"
    And I should see "Collections: Hidden Treasury"
  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/F"
  When I view the "F/F" works index
  When I follow "RSS Feed"
  Then I should see "Old Snippet"
    And I should not see "myname1"
    And I should see "author"
  When I view the "F/F" tag feed
  Then I should see "Old Snippet"
    And I should see "/tags/"
    And I should not see "myname1"
    And I should see "author"
  When I view the "F/M" tag feed
  Then I should not see "/tags/"
  Then I should see "GPL by the OTW"
