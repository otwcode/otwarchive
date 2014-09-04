@admin
Feature: Admin Actions to Post FAQs
  As an an admin
  I want to be able to manage the archive FAQ
  
Scenario: Post a FAQ
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I should not see "Some text"
    When I follow "New FAQ Section"
      And I fill in "content" with "Some text, that is sufficiently long to pass validation."
      And I fill in "title" with "New subsection"
    When I press "Post"
    Then I should see "Archive FAQ was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"

  Scenario: Edit FAQ
    Given I have posted a FAQ
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I follow "Edit"
      And I fill in "content" with "Number 1 posted FAQ, this is, and Yoda approves."
      And I press "Post"
    Then I should see "Archive FAQ was successfully updated"
      And I should see "Yoda approves"