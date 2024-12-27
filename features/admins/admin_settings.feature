@admin
Feature: Admin Settings Page
  In order to improve performance
  As an admin
  I want to be able to control downloading and tag wrangling.

  Scenario: Turn off downloads
    Given downloads are off
      And I have a work "Storytime"
    When I log out
      And I view the work "Storytime"
    Then I should not see "Download"
    When I am logged in as "tester"
      And I view the work "Storytime"
    Then I should not see "Download"

  Scenario: Turn off tag wrangling
    Given tag wrangling is off
      And the following activated tag wrangler exists
        | login           |
        | dizmo           |
      And a canonical character "Ianto Jones"
    When I am logged in as "dizmo"
      And I edit the tag "Ianto Jones"
    Then I should see "Wrangling is disabled at the moment. Please check back later."
      And I should not see "Synonym of"

  Scenario: Turn off Support form
    Given the support form is disabled and its text field set to "Please don't contact us"
    When I am logged in as a random user
      And I go to the support page
    Then I should see "Please don't contact us"

  Scenario: Turn on Support form
    Given the support form is enabled
    When I am logged in as a random user
      And I go to the support page
    Then I should see "We can answer Support inquiries in"

  Scenario Outline: Guests can comment when guest coments are enabled
    Given guest comments are on
      And I am logged out
      And <commentable>
      And <commentable> with guest comments enabled
      And I view <commentable> with comments
    When I post a guest comment
    Then I should see a link "Reply"

    Examples:
        | commentable |
        | the work "Generic Work" |
        | the admin post "Generic Post" |

  Scenario Outline: Guests cannot comment when guest comments are disabled, even if works or admin posts allow commets
    Given guest comments are off
      And I am logged out
      And <commentable>
      And <commentable> with guest comments enabled
      And a guest comment on <commentable>
    When I view <commentable> with comments
    Then I should see "Sorry, the Archive doesn't allow guests to comment right now."
      And I should not see a link "Reply"
    When I am logged in
      And I view <commentable> with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I am logged in as a super admin
      And I view <commentable> with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."

    Examples:
        | commentable |
        | the work "Generic Work"  |
        | the admin post "Generic Post" |

  Scenario: Turn off guest comments (when the work itself does not allow guest comments)
    Given guest comments are off
      And I am logged in as "author"
      And I set up the draft "Generic Work"
      And I choose "Only registered users can comment"
      And I post the work without preview
      And a comment "Nice job" by "user" on the work "Generic Work"
    When I am logged out
      And I view the work "Generic Work" with comments
    Then I should see "Sorry, the Archive doesn't allow guests to comment right now."
      And I should not see a link "Reply"
    When I am logged in
      And I view the work "Generic Work" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I am logged in as a super admin
      And I view the work "Generic Work" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."

  Scenario: Turn off guest comments (when the admin post itself does not allow guest comments)
    Given guest comments are off
      And I have posted an admin post with guest comments disabled
      And a comment "Nice job" by "user" on the admin post "Default Admin Post"
    When I view the admin post "Default Admin Post" with comments
    Then I should see "Sorry, the Archive doesn't allow guests to comment right now."
      And I should not see a link "Reply"
    When I am logged in
      And I view the admin post "Default Admin Post" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I am logged in as a super admin
      And I view the admin post "Default Admin Post" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."

  Scenario: Turn off guest comments (when work itself does not allow any comments)
    Given guest comments are off
      And I am logged in as "author"
      And I post the work "Generic Work"
      And a guest comment on the work "Generic Work"
      And I edit the work "Generic Work"
      And I choose "No one can comment"
      And I press "Post"
    When I am logged out
      And I view the work "Generic Work" with comments
    Then I should see "Sorry, the Archive doesn't allow guests to comment right now."
      And I should not see a link "Reply"
    When I am logged in
      And I view the work "Generic Work" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I am logged in as a super admin
      And I view the work "Generic Work" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."

  Scenario: Turn off guest comments (when the admin post itself does not allow any comments)
    Given guest comments are off
      And I have posted an admin post with comments disabled
      And a comment "Nice job" by "user" on the admin post "Default Admin Post"
    When I view the admin post "Default Admin Post" with comments
    Then I should see "Sorry, the Archive doesn't allow guests to comment right now."
      And I should not see a link "Reply"
    When I am logged in
      And I view the admin post "Default Admin Post" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I am logged in as a super admin
      And I view the admin post "Default Admin Post" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."

  Scenario: Tag comments are not affected when guest comments are turned off
    Given guest comments are off
      And a fandom exists with name: "Stargate SG-1", canonical: true
    When I am logged in as a tag wrangler
      And I view the tag "Stargate SG-1" with comments
    Then I should not see "Sorry, the Archive doesn't allow guests to comment right now."
    When I post the comment "Sent you a syn" on the tag "Stargate SG-1"
    Then I should see "Comment created!"
