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

  Scenario: Mystery work is not shown in feed

  Given basic tags
    And I am logged in as "myname2"
  Given I have a hidden collection "Hidden Treasury" with name "hidden_treasury"
  When I am logged in as "myname1"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "hidden_treasury"
    And I check "F/F"
    And I press "Update"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/F"
  When I view the "F/F" works index
  When I follow "RSS Feed"
  Then I should not see "Old Snippet"
    And I should not see "myname1"
    And I should see "author"

  Scenario: Author of anonymous work is not shown in feed

  Given basic tags
    And I am logged in as "myname2"
  Given I have an anonymous collection "Hidden Treasury" with name "hidden_treasury"
  When I am logged in as "myname1"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "hidden_treasury"
    And I check "F/F"
    And I press "Update"
    And all indexing jobs have been run
  Then I should see "Anonymous"
    And I should see "Collections: Hidden Treasury"
  When I am logged in as "author"
    And I post a work "My Work Title" with category "F/F"
  When I view the "F/F" works index
  When I follow "RSS Feed"
  Then I should see "Old Snippet"
    And I should not see "myname1"
    And I should see "author"

  Scenario: A user can see a feed for non canonical tags

  Given I am logged in as "author"
    And I post the work "Glorious" with fandom "SGA"
  When I view the "SGA" works feed
  Then I should see "Glorious"

  Scenario: Work authors are listed separately and absolutely linked
    Given the work "Glorious" by "author" with fandom "SGA"
      And a chapter with the co-author "cocreator" is added to "Glorious"
    When I view the "SGA" works feed
    Then the feed should have exactly 2 authors
      And the 1st feed author should contain "http://www.example.com/users/author/pseuds/author"
      And the 2nd feed author should contain "http://www.example.com/users/cocreator/pseuds/cocreator"

  Scenario: External authors on imported works are listed separately without links
    Given I set up importing with a mock website as an archivist
      And I import the work "http://example.com/second-import-site-with-tags" by "author" with email "a@ao3.org" and by "cocreator" with email "b@ao3.org"
      And I edit the work "Huddling"
      And I unlock the work
      And I press "Update"
    When I view the "OTW RPF" works feed
    Then I should see "Huddling"
      And the feed should have exactly 2 authors
      And the 1st feed author should contain "author [archived by archivist]"
      And the 1st feed author should not have a link
      And the 2nd feed author should contain "cocreator [archived by archivist]"
      And the 2nd feed author should not have a link
