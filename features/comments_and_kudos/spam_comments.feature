@comments
Feature: Marking comments as spam

  Scenario: Spam comments are not included in a work's comment count
    Given I am logged in as "author"
      And I post the work "Popular Fic" with guest comments enabled
      And I log out
      And I view the work "Popular Fic" with comments
      And I post a guest comment
      And I post a spam comment
      And all comments by "spammer" are marked as spam

    When I am logged in as "author"
      And I go to the home page
    Then I should see "This was really lovely!"
      And I should not see "Buy my product!"
    When I follow "My Inbox"
    Then I should see "(1 comments, 1 unread)"
      And I should see "This was really lovely!"
      And I should not see "Buy my product!"

    When I go to author's user page
    Then I should see "Popular Fic"
      And I should see "Comments: 1"

    When I follow "Popular Fic"
    Then I should see "Comments:1"
      And I should see "Comments (1)"

    When I am logged in as "author"
      And I go to my stats page
    Then I should see "Comment Threads: 1"

  Scenario: Spam comments are not included in an admin post's comment count
    Given I am logged in as a "communications" admin
      And I make an admin post
      And I log out
      And I go to the admin-posts page
      And I follow "Default Admin Post"
      And I post a guest comment
      And I post a spam comment
      And all comments by "spammer" are marked as spam

    When I go to the admin-posts page
    Then I should see "Default Admin Post (1)"

    When I follow "Default Admin Post"
    Then I should see "Comments (1)"

  Scenario: Author can mark comments as spam
    Given I am logged in as "author"
      And I post the work "Popular Fic" with guest comments enabled
      And I log out
    When I view the work "Popular Fic" with comments
      And I post a spam comment
      And I post a guest comment
      And I am logged in as "author"
      And I view the work "Popular Fic" with comments
    Then I should see "Comments (2)"
      And I should see "Buy my product"
    When I mark the comment as spam
    Then I should see "Comments (1)"
      And I should not see "Buy my product"

  @javascript
  Scenario: If Javascript is enabled, there's a confirmation popup before marking a comment as spam
    Given the work "Popular Fic" by "author"
      And a guest comment on the work "Popular Fic"
      And a guest comment on the work "Popular Fic"
    When I am logged in as "author"
      And I view the work "Popular Fic" with comments
    Then I should see "Comments (2)"
    When I mark the comment as spam
      And I confirm I want to mark the comment as spam
      And I view the work "Popular Fic" with comments
    Then I should see "Comments (1)"

  Scenario: Guest comments should be spam-checked
    Given <commentable>
      And <commentable> with guest comments enabled
    When I view <commentable> with comments
      And Akismet will flag any comment by spammer
      And I try to post a spam comment
    Then I should see "This comment looks like spam to our system, sorry!"

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |
  
  Scenario: New users' comments should be spam-checked on posting when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
      And Akismet will flag any comment by spammer
    When I am logged in as a new user "good_user"
      And I view <commentable> with comments
      And I post the comment "I don't like spam" on <commentable>
    Then I should see "Comment created!"
    When I am logged in as a new user "spammer"
      And I view <commentable> with comments
      And I post the comment "I like spam" on <commentable>
    Then I should see "This comment looks like spam to our system, sorry!"

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |

  Scenario: New user's comments should be spam-checked on editing when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
      And Akismet will flag any comment containing "spam"
    When I am logged in as a new user "spammer"
      And I view <commentable> with comments
      And I post the comment "I like ham" on <commentable>
    Then I should see "Comment created!"
    When I follow "Edit"
      And I fill in "Comment" with "I like spam"
      And I press "Update"
    Then I should see "This comment looks like spam to our system, sorry!"

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |

  Scenario: Old users' comments should not be spam-checked when the admin setting is enabled
    Given <commentable>
      And account age threshold for comment spam check is set to 5 days
      And Akismet will flag any comment by spammer
    When I am logged in as a new user "good_user"
      And it is currently 10 days from now
      And I post the comment "I don't like spam" on <commentable>
    Then I should see "Comment created!"
    When I am logged in as a new user "spammer"
      And it is currently 10 days from now
      And I post the comment "I like spam" on <commentable>
    Then I should see "Comment created!"

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |

  Scenario: New users' comments should not be spam-checked if the admin setting is disabled
    Given <commentable>
      And account age threshold for comment spam check is set to 0 days
      And Akismet will flag any comment by spammer
    When I am logged in as a new user "good_user"
      And I post the comment "I don't like spam" on <commentable>
    Then I should see "Comment created!"
    When I am logged in as a new user "spammer"
      And I post the comment "I like spam" on <commentable>
    Then I should see "Comment created!"

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |

  Scenario: New users' comments should not be spam-checked on tags
    Given a canonical fandom "Stargate SG-1"
      And the tag wrangler "spammer" with password "password" is wrangler of "Stargate SG-1"
      And account age threshold for comment spam check is set to 5 days
      And Akismet will flag any comment by spammer
    When I am logged in as a new user "spammer"
      And I view the tag "Stargate SG-1" with comments
      And I post the comment "Sent you a syn" on the tag "Stargate SG-1"
    Then I should see "Comment created!"
