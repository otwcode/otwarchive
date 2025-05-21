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
    And I post a guest comment "Hello <img src='https://example.com/image.jpg' alt='baz'>"
  Then I should see "Hello img src="
    And I should see "https://example.com/image.jpg"
    And I should see "alt="
    And I should see "baz"
    But I should not see the image "src" text "https://example.com/image.jpg"
