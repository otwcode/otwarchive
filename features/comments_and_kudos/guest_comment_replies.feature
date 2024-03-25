Feature: Disallowing guest comment replies

  Scenario Outline: Guests cannot reply to a user who has guest comments off on news posts and other users' works
    Given <commentable>
      And <commentable> with guest comments enabled
      And the user "commenter" turns off guest comment replies
      And a comment "OMG!" by "commenter" on <commentable>
    When I view <commentable> with comments
    Then I should see a "Comment" button
      But I should not see a link "Reply"
    When I am logged in as "reader"
      And I view <commentable> with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"

    Examples:
      | commentable                 |
      | the work "Aftermath"        |
      | the admin post "Change Log" |

  Scenario: Guests can reply to a user who has guest comments off on their own work
    Given the work "Aftermath" by "creator" with guest comments enabled
      And the user "creator" turns off guest comment replies
      And a comment "OMG!" by "creator" on the work "Aftermath"
    When I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"
    When I am logged in as "reader"
      And I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"

  Scenario: Guests can reply to a user who has guest comments off on works co-created by the user
    Given the user "nemesis" turns off guest comment replies
      And the work "Aftermath" by "creator" and "nemesis" with guest comments enabled
      And a comment "OMG!" by "nemesis" on the work "Aftermath"
    When I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"
    When I am logged in as "reader"
      And I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"

  Scenario: Users can reply to a user who has guest comments off on tags
    Given the following activated tag wranglers exist
      | login     |
      | commenter |
      | wrangler  |
      And a canonical fandom "Controversial"
      And the user "commenter" turns off guest comment replies
      And a comment "OMG!" by "commenter" on the tag "Controversial"
    When I am logged in as "wrangler"
      And I view the tag "Controversial" with comments
      And I follow "Reply"
      And I fill in "Comment" with "Ugh." within ".odd"
      And I press "Comment" within ".odd"
    Then I should see "Comment created!"

  Scenario: Guests can reply to guests
    Given the work "Aftermath"
      And the work "Aftermath" with guest comments enabled
      And a guest comment on the work "Aftermath"
    When I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"
    When I am logged in as "reader"
      And I view the work "Aftermath" with comments
    Then I should see a "Comment" button
      And I should see a link "Reply"
