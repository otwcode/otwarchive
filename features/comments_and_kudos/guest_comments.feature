@comments
Feature: Read guest comments
  In order to tell guest comments from logged-in users' comments
  As a user
  I'd like to see the "guest" sign

Scenario: View guest comments in homepage, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3" with guest comments enabled
    And I am logged out
  When I post a guest comment
  Then I should see "(Guest)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should see "(Guest)"
  When I follow "My Inbox"
  Then I should see "(Guest)"
  When I view the work "My very meta work about AO3" with comments
  Then I should see "(Guest)"

Scenario: View logged-in comments in homepage, inbox and works
  Given I am logged in as "normal_user"
    And I post the work "My very meta work about AO3"
    And I am logged in as "logged_in_user"
  When I post the comment ":)))))))" on the work "My very meta work about AO3"
  Then I should not see "(Guest)"
  When I am logged in as "normal_user"
    And I go to the home page
  Then I should not see "(Guest)"
  When I follow "My Inbox"
  Then I should not see "(Guest)"
  When I view the work "My very meta work about AO3" with comments
  Then I should not see "(Guest)"

Scenario: Guest comments with embedded images are rendered as plain text
  Given I am logged in as "normal_user"
    And I post the work "foobar" with guest comments enabled
    And I am logged out
  When I view the work "foobar"
  Then I should see "Embedded images (<img> tags) will be displayed as HTML" within ".new_comment"
  When I post a guest comment "Hello <img src='https://example.com/image.jpg' alt='baz'>"
  Then I should see "Hello img src="
    And I should see "https://example.com/image.jpg"
    And I should see "alt="
    And I should see "baz"
    But I should not see the image "src" text "https://example.com/image.jpg"

Scenario: Guest sees warning footnote and required fields on comment form
  Given the work "Test Work" by "author" with guest comments enabled
  When I go to the work "Test Work"
  Then I should see "You will not be able to edit or delete your comment after it is posted."
  And I should see "Guest name (required)"
  And I should see "Guest email (required)"
  And I should see "All fields are required. Your name and comment text will both be publicly displayed. Your email address will not be made public, but it will be used to send you notifications of any replies to your comment."

Scenario: Logged-in user does not see guest-specific elements
  Given the work "Test Work" by "author" with guest comments enabled
  And I am logged in as "commenter"
  When I go to the work "Test Work"
  Then I should not see "You will not be able to edit or delete your comment after it is posted."
  And I should not see "Guest name (required)"
  And I should not see "Guest email (required)"
  And I should not see "All fields are required. Your name and comment text will both be publicly displayed. Your email address will not be made public, but it will be used to send you notifications of any replies to your comment."

Scenario: Guest comment validation messages appear correctly
  Given the work "Test Work" by "author" with guest comments enabled
  When I go to the work "Test Work"
  And I try to submit a comment without filling required fields
  Then I should see validation messages for guest name and email
