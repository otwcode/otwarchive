@javascript
Feature: Rich text editor for Comments
  Scenario Outline: Using the RTE with hotkeys
    Given <commentable>
    When I am logged in as "commenter"
      And I view <commentable> with comments
    Then I should see "Rich Text"
    When I follow "Rich Text"
      And I send keys "hello" to Lexxy
      And I send keys "[:control, b]" to Lexxy
      And I send keys ":space" to Lexxy
      And I send keys "world" to Lexxy
    And I press "Comment"
      Then I should see "Comment created!"
      And I should see the text with tags "<p>hello<strong> world</strong></p>"
    When I follow "Rich Text"
      And I send keys "example website" to Lexxy
      And I send keys "[:control, a]" to Lexxy
      And I send keys "[:control, k]" to Lexxy
      And I send keys "https://example.com" to 'input[inputmode="url"]'
      And I press "Link" within "div[data-dropdown-panel]"
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see the text with tags '<p><a href="https://example.com" rel="nofollow">example website</a></p>'

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Using the RTE for replying
    Given <commentable>
      And a comment "This is beautiful" by "commenter" on <commentable>
    When I am logged in as "creator"
      And I view <commentable> with comments
      And I follow "Reply" within ".odd"
    Then I should see "Rich Text" within ".odd"
    When I follow "Rich Text" within ".odd"
      And I send keys "Thank you!" to Lexxy
      And I press "Comment" within ".odd"
    Then I should see "Comment created!"
      And I should see "Thank you!" within ".thread"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Using the RTE for replying, in a thread
    Given <commentable>
      And a comment "This is beautiful" by "commenter" on <commentable>
    When I am logged in as "creator"
      And I view <commentable> with comments
      And I follow "Thread"
      And I follow "Reply" within ".odd"
    Then I should see "Rich Text" within ".odd"
    When I follow "Rich Text" within ".odd"
      And I send keys "Thank you!" to Lexxy
      And I press "Comment" within ".odd"
    Then I should see "Comment created!"
      And I should see "Thank you!" within ".thread"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Using the RTE for editing a comment
    Given <commentable>
      And a comment "This is OK" by "commenter" on <commentable>
    When I am logged in as "commenter"
      And it is currently 1 second from now
      And I view <commentable> with comments
      And I follow "Edit"
      And I follow "Rich Text" within ".odd"
      And I send keys "[:control, a]" to Lexxy
      And I send keys "Actually, this is awesome" to Lexxy
      And I press "Update"
    Then I should see "Actually, this is awesome"
    But I should not see "This is OK"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Using the RTE for editing a comment, in a thread
    Given <commentable>
      And a comment "This is OK" by "commenter" on <commentable>
    When I am logged in as "commenter"
      And it is currently 1 second from now
      And I view <commentable> with comments
      And I follow "Thread"
      And I follow "Edit"
      And I follow "Rich Text" within ".odd"
      And I send keys "[:control, a]" to Lexxy
      And I send keys "Actually, this is awesome" to Lexxy
      And I press "Update"
    Then I should see "Actually, this is awesome"
    But I should not see "This is OK"
    When I reload the page
    Then I should see "Comment was successfully updated"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Using the RTE as a guest
    Given guest comments are on
      And I am logged out
      And <commentable>
      And <commentable> with guest comments enabled
      And I view <commentable> with comments
    Then I should see "Rich Text"
    When I follow "Rich Text"
      And I fill in "comment[name]" with "guest"
      And I fill in "comment[email]" with "guest@example.org"
      And I send keys "cats" to Lexxy
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see the text with tags "<p>cats</p>"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario Outline: Getting out of editor area with keyboard
    Given <commentable>
    When I am logged in as "commenter"
      And I view <commentable> with comments
    Then I should see "Rich Text"
    When I follow "Rich Text"
      And I send keys "cats" to Lexxy
      And I press the "tab" key
      And I press the "tab" key
      And I press the "enter" key
    Then I should see "Comment created!"
      And I should see the text with tags "<p>cats</p>"

    Examples:
      | commentable |
      | the work "Generic Work" |
      | the admin post "Five Things" |

  Scenario: Using the RTE from inbox
    Given the work "Generic Work" by "creator"
      And I am logged in as "commenter"
      And I post the comment "This is awesome!" on the work "Generic Work"
    When I am logged in as "creator"
      And I go to creator's inbox page
    Then I should see "commenter on Generic Work"
      And I should see "This is awesome!"
      And I should see a link "Reply"
    When I follow "Reply"
      And I follow "Rich Text"
      And I send keys "Thank you so much!" to Lexxy
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see "replied to"
    When I go to the homepage
    Then I should not see "Unread messages"
      And I should not see "This is awesome!"
    When I am logged in as "commenter"
      And I go to the homepage
    Then I should see "creator on Generic Work"
      And I should see "Thank you so much!"

  Scenario: Using the RTE from the home page
    Given the work "Generic Work" by "creator"
      And I am logged in as "commenter"
      And I post the comment "This is awesome!" on the work "Generic Work"
    When I am logged in as "creator"
      And I go to the homepage
    Then I should see "commenter on Generic Work"
      And I should see "This is awesome!"
      And I should see a link "Reply"
    When I follow "Reply" within ".latest.messages.module"
      And I follow "Rich Text"
      And I send keys "Thank you so much!" to Lexxy
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see "Thank you so much!" within ".thread"
    When I go to the homepage
    Then I should not see "Unread messages"
      And I should not see "This is awesome!"
    When I am logged in as "commenter"
      And I go to the homepage
    Then I should see "creator on Generic Work"
      And I should see "Thank you so much!"

  Scenario Outline: Trying to send an empty comment with RTE
    Given <commentable>
      And I am logged in as "commenter"
      And I view <commentable> with comments
    Then I should see "Rich Text"
    When I follow "Rich Text"
      And I press "Comment"
    Then I should not see "Comment created!"
    When I send keys "cats" to Lexxy
      And I press "Comment"
    Then I should see "Comment created!"
      And I should see the text with tags "<p>cats</p>"

    Examples:
      | commentable                  |
      | the work "Generic Work"      |
      | the admin post "Five Things" |

  Scenario Outline: Checking character counter while using RTE
    Given <commentable>
      And I am logged in as "commenter"
      And I view <commentable> with comments
    Then I should see "Rich Text"
    When I follow "Rich Text"
      And I send keys "a" to Lexxy
    Then I should see "9992 characters left"
    When I send keys ":backspace" to Lexxy
    Then I should see "10000 characters left"
    When I send keys "cats! cats!" to Lexxy
    Then I should see "9982 characters left"

    Examples:
      | commentable                  |
      | the work "Generic Work"      |
      | the admin post "Five Things" |

  Rule: Screwing around with RTE content
    Background:
      Given the work "Generic Work"
        And I am logged in as "commenter"
        And I view the work "Generic Work"

    Example: Enter comment to RTE, submit
      When I follow "Rich Text"
        And I send keys "cats" to Lexxy
        And I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"

    Example: Enter comment to RTE, switch to HTML, submit
      When I follow "Rich Text"
        And I send keys "cats" to Lexxy
        And I follow "HTML"
      Then I should see "cats"
      When I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"

    Example: Enter comment to HTML, switch to RTE, submit
      When I send keys "cats" to HTML editor
        And I follow "Rich Text"
      Then I should see "cats"
      When I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"

    Example: Enter comment to RTE, switch to HTML, switch to RTE, submit
      When I follow "Rich Text"
        And I send keys "cats" to Lexxy
        And I follow "HTML"
      Then I should see "cats"
      When I follow "Rich Text"
      Then I should see "cats"
      When I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"

    Example: Enter comment to HTML, switch to RTE, switch to HTML, submit
      When I send keys "cats" to HTML editor
        And I follow "Rich Text"
      Then I should see "cats"
      When I follow "HTML"
      Then I should see "cats"
      When I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"

      # TODO
    Example: Enter comment to RTE, switch to HTML, delete all content, submit
      When I follow "Rich Text"
        And I send keys "cats" to Lexxy
        And I follow "HTML"
        And I send keys "[:control, a]" to HTML editor
        And I send keys ":backspace" to HTML editor
        And I press "Comment"
      Then I should not see "Comment created!"
        And I should not see "cats"

    Example: Enter comment to HTML, switch to RTE, delete all content, submit
      When I send keys "cats" to HTML editor
        And I follow "Rich Text"
        And I send keys "[:control, a]" to Lexxy
        And I send keys ":backspace" to Lexxy
        And I press "Comment"
      Then I should not see "Comment created!"
        And I should not see "cats"

      # TODO
    Example: Switch to RTE and back to HTML, enter comment and submit
      When I follow "Rich Text"
        And I follow "HTML"
        And I send keys "cats" to HTML editor
        And I press "Comment"
      Then I should see "Comment created!"
        And I should see the text with tags "<p>cats</p>"
