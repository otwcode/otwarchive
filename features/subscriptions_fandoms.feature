Feature: Subscriptions
  In order to follow aa fandom I like
  As a reader
  I want to subscribe to it

  Scenario: Subscribe to a test fandom when there are no works in it

  When I am logged in as "author"
    And I post a work with category "M/F"
  When I am logged in as "reader"
    And I view the "F/F" works index
  Then I should see "Subscribe to the RSS Feed"
  # TODO: If you uncomment the next line, it fails horribly. Is this a genuine bug, or a cucumber error?
  # When I follow "Subscribe to the RSS Feed"
  # Then I should not see "My Work Title"
  #   And I should not see "Stargate SG-1"
    
  Scenario: Subscribe to a test fandom when there are works in it
  
  When I am logged in as "author"
    And I post a work with category "F/F"
  When I am logged in as "reader"
    And I view the "F/F" works index
  Then I should see "Subscribe to the RSS Feed"
  When I follow "Subscribe to the RSS Feed"
  Then I should see "My Work Title"
    And I should see "Stargate SG-1"

  Scenario: Subscribe to a non-test fandom
  
  When I am logged in as "author"
    And I post a work with category "Multi"
  When I am logged in as "reader"
    And I view the "Multi" works index
  Then I should not see "Subscribe to the RSS Feed"

  Scenario: Mystery work is not shown in feed
  
  Scenario: Author of anonymous work is not shown in feed
    
   
