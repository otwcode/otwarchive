@comments
Feature: Granular comment rate limiting

  Scenario: Guest commenter is not affected by rate limits
    Given account age threshold for comment spam check is set to 5 days
      And the work "Spam target" by "joe" with guest comments enabled
      And I am logged out
    When I view the work "Spam target"
      And I post a guest comment
      And I post a guest comment "This was really lovely twice!"
      And I post a guest comment "This was really lovely thrice!"
      And I post a guest comment "This was really lovely 4!"
    Then I should see "Comments (4)"
      But I should not see "Error 429"

  Scenario: Work creator is not affected by rate limits
    Given account age threshold for comment spam check is set to 5 days
      And the work "Spam target" by "joe" with guest comments enabled
    When I am logged in as a new user "joe"
      And I post the comment "Hello!" on the work "Spam target"
      And I post the comment "Hello again!" on the work "Spam target"
      And I post the comment "Hello again again!" on the work "Spam target"
      And I post the comment "Hello Hello!" on the work "Spam target"
    Then I should see "Comments (4)"
      But I should not see "Error 429"

  Scenario: Tag comments are not affected by rate limits
    Given account age threshold for comment spam check is set to 5 days
      And a canonical fandom "Stargate SG-1"
      And I am logged in as a tag wrangler
      And I view the tag "Stargate SG-1" with comments
      And I post the comment "Hey" on the tag "Stargate SG-1"
      And I post the comment "Hello again!" on the tag "Stargate SG-1"
      And I post the comment "Hello there!" on the tag "Stargate SG-1"
      And I post the comment "Hello Hello!" on the tag "Stargate SG-1"
    Then I should see "Hey"
      And I should see "Hello again!"
      And I should see "Hello there!"
      And I should see "Hello Hello!"
      But I should not see "Error 429"

  Scenario Outline: New users' comments should be rate limited on posting when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
    When I am logged in as a new user "naughty"
      And I view <commentable> with comments
      And I post the comment "One comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Two comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Three comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Four comment" on <commentable>
    Then I should see "Error 429"

    Examples:
      | commentable |
      | the work "Generic Work"  |
      | the admin post "Generic Post" |

  Scenario Outline: Unrelated new user is not affected by other user getting rate limited
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
    When I am logged in as a new user "naughty"
      And I view <commentable> with comments
      And I post the comment "One comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Two comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Three comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Four comment" on <commentable>
    Then I should see "Error 429"
    When I am logged in as a new user "nice"
      And I view <commentable> with comments
      And I post the comment "Hey hey" on <commentable>
    Then I should see "Comments (4)"

    Examples:
      | commentable |
      | the work "Generic Work"  |
      | the admin post "Generic Post" |

  Scenario Outline: New users' comments should be rate limited on editing when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
    When I am logged in as a new user "naughty"
      And I view <commentable> with comments
      And I post the comment "abcdefghijk" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Two comment" on <commentable>
    Then I should see "Comment created!"
    When I follow "Thread"
      And I follow "Edit"
      And I fill in "Comment" with "edited somehow"
      And it is currently 1 second from now
      And I press "Update"
    Then I should see "edited somehow"
    When I follow "Thread"
      And I follow "Edit"
      And I fill in "Comment" with "edited again"
      And it is currently 1 second from now
      And I press "Update"
    Then I should see "Error 429"

    Examples:
      | commentable |
      | the work "Generic Work"  |
      | the admin post "Generic Post" |

  Scenario Outline: Old users' comments should not be rate limited when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
    When I am logged in as a new user "naughty"
      And it is currently 20 days from now
      And I view <commentable> with comments
      And I post the comment "One comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Two comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Three comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Four comment" on <commentable>
    Then I should see "Comments (4)"
      But I should not see "Error 429"

    Examples:
      | commentable |
      | the work "Generic Work"  |
      | the admin post "Generic Post" |

  Scenario Outline: New users' comments should not be rate limited when the admin setting is disabled
    Given <commentable>
      And account age threshold for comment spam check is set to 0 days
    When I am logged in as a new user "naughty"
      And I view <commentable> with comments
      And I post the comment "One comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Two comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Three comment" on <commentable>
    Then I should see "Comment created!"
      And I post the comment "Four comment" on <commentable>
    Then I should see "Comments (4)"
      But I should not see "Error 429"

    Examples:
      | commentable |
      | the work "Generic Work"  |
      | the admin post "Generic Post" |
