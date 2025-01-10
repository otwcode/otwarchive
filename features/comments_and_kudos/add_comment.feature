@comments
Feature: Comment on work
  In order to give feedback
  As a reader
  I'd like to comment on a work

Scenario: Comment links from downloads and static pages

  Given the work "Generic Work"
  When I am logged in as "commenter"
    And I visit the new comment page for the work "Generic Work"
  Then I should see the comment form

Scenario: When logged in I can comment on a work

  Given the work "The One Where Neal is Awesome"
  When I am logged in as "commenter"
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved this! 😍🤩"
    And I press "Comment"
  Then I should see "Comment created!"
    And I should see "I loved this! 😍🤩" within ".odd"

  Scenario: When a one-shot work becomes multi-chapter, all previous comments say "on Chapter 1"
    Given the work "The One Where Neal is Awesome"
      And I am logged in as "commenter"
      And I post the comment "I loved this! 😍🤩" on the work "The One Where Neal is Awesome"
    When I view the work "The One Where Neal is Awesome" with comments
    Then I should not see "commenter on Chapter 1" within "h4.heading.byline"
    When a chapter is added to "The One Where Neal is Awesome"
      And I view the work "The One Where Neal is Awesome" in full mode
      And I follow "Comments (1)"
    When "AO3-4214" is fixed
    # Then I should see "commenter on Chapter 1" within "h4.heading.byline"

Scenario: I cannot comment with a pseud that I don't own

  Given the work "Random Work"
  When I attempt to comment on "Random Work" with a pseud that is not mine
  Then I should not see "Comment created!"
    And I should not see "on Chapter 1"
    And I should see "You can't comment with that pseud"

Scenario: I cannot edit in a pseud that I don't own

  Given the work "Random Work"
  When I attempt to update a comment on "Random Work" with a pseud that is not mine
  Then I should not see "Comment was successfully updated"
    And I should see "You can't comment with that pseud"

Scenario: Comment editing

  When I am logged in as "author"
    And I post the work "The One Where Neal is Awesome"
  When I am logged in as "commenter"
    And I post the comment "Mistaken comment" on the work "The One Where Neal is Awesome"
    And it is currently 1 second from now
    And I follow "Edit"
    And I fill in "Comment" with "Actually, I meant something different"
    And I press "Update"
  Then I should see "Comment was successfully updated"
    And I should see "Actually, I meant something different"
    And I should not see "Mistaken comment"
    And I should see Last Edited in the right timezone

Scenario: Comment threading, comment editing

  When I am logged in as "author"
    And I post the work "The One Where Neal is Awesome"
  When I am logged in as "commenter"
    And I post the comment "I loved this!" on the work "The One Where Neal is Awesome"
  When I follow "Reply"
    And I fill in "Comment" with "I wanted to say more." within ".odd"
    And I press "Comment" within ".odd"
  Then I should see "Comment created!"
    And I should see "I wanted to say more." within ".even"
  When I am logged in as "commenter2"
    And I view the work "The One Where Neal is Awesome"
    And I fill in "Comment" with "I loved it, too."
    And I press "Comment"
  Then I should see "Comment created!"
    And I should see "I loved it, too."
  When I am logged in as "author"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (3)"
    And I follow "Reply" within ".even"
    And I fill in "Comment" with "Thank you." within ".even"
    And I press "Comment" within ".even"
  Then I should see "Comment created!"
    And I should see "Thank you." within "ol.thread li ol.thread li ol.thread li"
  When I am logged in as "commenter"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (4)"
    And I follow "Reply" within ".thread .thread .odd"
    And I fill in "Comment" with "Mistaken comment" within ".thread .thread .odd"
    And I press "Comment" within ".thread .thread .odd"
    And it is currently 1 second from now
    And I follow "Edit" within "ol.thread li ol.thread li ol.thread li ol.thread ul.actions"
    And I fill in "Comment" with "Actually, I meant something different"
    And I press "Update"
  Then I should see "Comment was successfully updated"
    And I should see "Actually, I meant something different"
    And I should not see "Mistaken comment"
    And I should see Last Edited in the right timezone
  When I am logged in as "commenter3"
    And I view the work "The One Where Neal is Awesome"
    And I follow "Comments (5)"
    And I follow "Reply" within ".thread .even"
    And I fill in "Comment" with "This should be nested" within ".thread .even"
    And I press "Comment" within ".thread .even"
  Then I should see "Comment created!"
    And I should not see "Mistaken comment"
    And I should see "Actually, I meant something different" within "ol.thread li ol.thread li ol.thread li ol.thread"
    And I should see "I loved it, too." within "ol.thread"
    And I should see "Thank you." within "ol.thread li ol.thread li ol.thread"
    And I should see "This should be nested" within "ol.thread li ol.thread li ol.thread"
    And I should not see "This should be nested" within ".thread .thread .thread .thread"
    And I should see "I loved this" within "ol.thread"

  Scenario: A leaves a comment, B replies to it, A deletes their comment, B edits the comment, A should not receive a comment edit notification email

    Given the work "Generic Work" by "creator"
      And a comment "A's comment (to be deleted)" by "User_A" on the work "Generic Work"
      And a reply "B's comment (to be edited)" by "User_B" on the work "Generic Work"
      And 1 email should be delivered to "User_A"
      And all emails have been delivered
    When I am logged in as "User_A"
      And I view the work "Generic Work" with comments
      And I delete the comment
    When I am logged in as "User_B"
      And I view the work "Generic Work" with comments
      And I follow "Edit"
      And I fill in "Comment" with "B's improved comment (edited)"
      And I press "Update"
    Then 0 emails should be delivered to "User_A"

  Scenario: Try to post an invalid comment

    When I am logged in as "author"
      And I post the work "Generic Work"
    When I am logged in as "commenter"
      And I view the work "Generic Work"
      And I compose an invalid comment
      And I press "Comment"
    Then I should see "must be less than"
      And I should see "Now, we can devour the gods, together!"
    When I fill in "Comment" with "This is a valid comment"
      And I press "Comment"
      And I follow "Reply" within ".thread .odd"
      And I compose an invalid comment within ".thread .odd"
      And I press "Comment" within ".thread .odd"
    Then I should see "must be less than"
      And I should see "Now, we can devour the gods, together!"
    When I fill in "Comment" with "This is a valid reply comment"
      And I press "Comment"
      And it is currently 1 second from now
      And I follow "Edit"
      And I compose an invalid comment
      And I press "Update"
    Then I should see "must be less than"
      And I should see "Now, we can devour the gods, together!"

Scenario: Don't receive comment notifications of your own comments by default

  When I am logged in as "author"
    And I post the work "Generic Work"
  When I am logged in as "commenter"
    And I post the comment "Something" on the work "Generic Work"
  Then "author" should be emailed
    And "commenter" should not be emailed

Scenario: Set preference and receive comment notifications of your own comments

  When I am logged in as "author"
    And I post the work "Generic Work"
  When I am logged in as "commenter"
    And I set my preferences to turn on copies of my own comments
    And I post the comment "Something" on the work "Generic Work"
  Then "author" should be emailed
    And "commenter" should be emailed
    And 1 email should be delivered to "commenter"

Scenario: Try to post a comment with a < angle bracket before a linebreak, without a space before the bracket

    Given the work "Generic Work"
      And I am logged in as "commenter"
      And I view the work "Generic Work"
    When I fill in "Comment" with
      """
      Here is a comment with a bracket
      abc<
      xyz
      """
      And I press "Comment"
    Then I should see "Comment created!"

Scenario: Try to post a comment with a < angle bracket before a linebreak, with a space before the bracket

    Given the work "Generic Work"
      And I am logged in as "commenter"
      And I view the work "Generic Work"
    When I fill in "Comment" with
      """
      Here is a comment with a bracket
      abc <
      xyz
      """
      And I press "Comment"
    Then I should see "Comment created!"

Scenario: Users with different time zone preferences should see the time in their own timezone
  Given the work "Generic Work"
    And I am logged in as "commenter"
    And I set my time zone to "UTC"
    And I post the comment "Something" on the work "Generic Work"
    And it is currently 1 second from now
    And I follow "Edit"
    And I fill in "Comment" with "Something else"
    And I press "Update"
  Then I should see "UTC" within ".posted.datetime"
    And I should see "UTC" within ".edited.datetime"
  When I am logged in as "reader"
    And I set my time zone to "Brisbane"
    And I view the work "Generic Work" with comments
  Then I should see "AEST" within ".posted.datetime"
    And I should see "AEST" within ".edited.datetime"

Scenario: It hides comment actions when a reply form is open
  Given the work "The One Where Neal is Awesome"
    And I am logged in as "commenter"
    And I post the comment "I loved this!" on the work "The One Where Neal is Awesome"
  When I follow "Reply"
  Then I should see "Comment as commenter"
    And I should not see "Thread"

@javascript
Scenario: It shows and hides cancel buttons properly
  Given the work "Aftermath" by "creator" with guest comments enabled
    And a comment "Ugh." by "pest" on the work "Aftermath"
  When I view the work "Aftermath"
    And I display comments
  Then I should see "Ugh."
  When I open the reply box
  Then I should see "Cancel"
    But I should not see "Reply"
  When I cancel the reply box
  Then I should not see "Cancel"
    But I should see "Reply"

@javascript
Scenario: It shows and hides cancel buttons properly even on a new page
Given the work "Aftermath" by "creator" with guest comments enabled
    And a comment "Ugh." by "pest" on the work "Aftermath"
  When I view the work "Aftermath"
    And I display comments
  Then I should see "Ugh."
  # Go to /chapters/XX?add_comment_reply_id=YY&show_comments=true#comment_YY"; akin to a Ctrl+Click on "Reply"
  When I reply on a new page
  Then I should see "Cancel"
    But I should not see "Reply"
  When I cancel the reply box
  Then I should not see "Cancel"
    But I should see "Reply"

Scenario: Cannot comment (no form) while logged as admin

    Given the work "Generic Work" by "creator" with guest comments enabled
      And I am logged in as an admin
      And I view the work "Generic Work"
    Then I should see "Generic Work"
      And I should not see "Post Comment"
      And I should not see a "Comment" button
      And I should see "Please log out of your admin account to comment."

Scenario: Cannot reply to comments (no button) while logged as admin

    Given the work "Generic Work" by "creator" with guest comments enabled
    When I am logged in as "commenter"
      And I view the work "Generic Work"
      And I post a comment "Woohoo"
    When I am logged in as an admin
      And I view the work "Generic Work"
      And I follow "Comments (1)"
    Then I should see "Woohoo"
      And I should not see "Reply"
    When I am logged out
      And I view the work "Generic Work"
      And I follow "Comments (1)"
    Then I should see "Woohoo"
      And I should see "Reply"
