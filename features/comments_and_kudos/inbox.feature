Feature: Get messages in the inbox 
  In order to stay informed about activity concerning my works and comments
  As a user
  I'd like to get messages in my inbox

  Scenario: I should not receive comments in my inbox if I have set my preferences to "Turn off messages to your inbox about comments."
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "Another Round"
      And I set my preferences to turn off messages to my inbox about comments
    When I am logged in as "cutman"
      And I post the comment "You should not receive this in your inbox." on the work "Another Round"
    When I am logged in as "boxer" with password "10987tko"
      And I go to my inbox page
    Then I should not see "cutman on Another Round"
      And I should not see "You should not receive this in your inbox."
  
  Scenario: I should receive comments in my inbox if I haven't set my preferences to "Turn off messages to your inbox about comments."
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "The Fight"
      And I set my preferences to turn on messages to my inbox about comments
    When I am logged in as "cutman"
      And I post the comment "You should receive this in your inbox." on the work "The Fight"
    When I am logged in as "boxer" with password "10987tko"
      And I go to my inbox page
    Then I should see "cutman on The Fight"
      And I should see "You should receive this in your inbox."

  Scenario: I should not receive my own comments in my inbox if I have set my preferences to "Turn off copies of your own comments."
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "Fighting Myself"
      And I set my preferences to turn off copies of my own comments
      And I post the comment "I should not see this in my inbox." on the work "Fighting Myself"
    When I go to my inbox page
    Then I should not see "boxer on Fighting Myself"
      And I should not see "I should not see this in my inbox."

  Scenario: I should receive my own comments in my inbox if I haven't set my preferences to "Turn off copies of your own comments."
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "Shadow Boxing"
      And I set my preferences to turn on copies of my own comments
      And I post the comment "I should see this in my inbox." on the work "Shadow Boxing"
    When I go to my inbox page
    Then I should see "boxer on Shadow Boxing"
      And I should see "I should see this in my inbox."
    
  Scenario: Logged in comments in my inbox should have timestamps
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "Down for the Count"
    When I am logged in as "cutman"
      And I post the comment "It was a right hook... with a bit of a jab. (And he did it with his left hand.)" on the work "Down for the Count"
    When I am logged in as "boxer" with password "10987tko"
      And I go to my inbox page
    Then I should see "cutman on Down for the Count"
      And I should see "less than 1 minute ago"
      
  Scenario: Logged in comments in my inbox should have timestamps
    Given I am logged in as "boxer" with password "10987tko"
      And I post the work "Down for the Count"
    When I post the comment "The fight game's complex." on the work "Down for the Count" as a guest
    When I am logged in as "boxer" with password "10987tko"
      And I go to my inbox page
    Then I should see "guest on Down for the Count"
      And I should see "less than 1 minute ago"  