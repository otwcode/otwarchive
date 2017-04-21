@admin
Feature: Admin Actions to Post FAQs
  As an an admin
  I want to be able to manage the archive FAQ
 
  Scenario: Post a FAQ
    Given I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I follow "New FAQ Category"
    Then I should see "Create New Archive FAQ Category"
      And I should see "Question 1"
      And the field labeled "Question*" should contain "This is a temporary question"
      And the field labeled "Anchor name*" should contain "ThisIsATemporaryAnchor"
      And the field labeled "Answer*" should contain "This is temporary content"
    When I fill in "Category name*" with "New subsection"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Anchor name*" with "whatisao3"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation"
    When I am logged out as an admin
      And I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should see "New subsection"
      And I should see "What is AO3?"
      And I should not see "New FAQ Category"
      And I should not see "Reorder FAQs"
    When I follow "What is AO3?"
    Then I should see "Some text, that is sufficiently long to pass validation."

  Scenario: Edit FAQ
    Given I have posted a FAQ
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I follow "Edit"
      And I fill in "Answer*" with "Number 1 posted FAQ, this is, and Yoda approves."
      And I press "Post"
    Then I should see "ArchiveFaq was successfully updated"
      And I should see "Yoda approves"
      And 0 emails should be delivered
    When I go to the archive_faqs page
      And I follow "Edit"
      And I fill in "Answer*" with "New Content, yay"
      And I check "archive_faq_notify_translations"
      And I press "Post"
    Then 1 email should be delivered

  Scenario: Post a FAQ that is a Translation of another
    Given basic languages
      And an FAQ category with multiple questions in the default language
    When I am logged in as an admin
      And I go to the de faq page
      # The filter options aren't working for tests, so we use the above for now
      # And I go to the archive_faqs page
      # And I select "Deutsch" from "Language"
      # And I press "Go"
    Then I should see "Default Language FAQ"
    When I follow "Edit"
    Then the FAQ fields should be populated with the default language version
    When I fill in "Category name*" with "Deutsch FAQ"
      And I translate question 1
      And I check "Question translated"
      And I check "Notify Translation Committee of changes you made in this FAQ category?"
      And I press "Post"
    Then I should see "ArchiveFaq was successfully updated."
      And 1 email should be delivered
      And I should see "Is this Deutsch question 1?"
      And I should see "Yes, and this is Deutsch answer 1."
      And I should not see "Is this question 1?"
      And I should not see "Yes, and this is answer 1."
      And I should not see "Is this question 2?"
      And I should not see "Yes, and this is answer 2."
    When I am logged out as an admin
      And I go to the de faq page
      # The filter options aren't working for tests, so we use the above for now
      # And I go to the archive_faqs page
      # And I select "Deutsch" from "Language"
      # And I press "Go"
    Then I should see "Deutsch FAQ"
      And I should see "Is this Deutsch question 1?"
      And I should not see "Is this question 1?"
      And I should not see "Is this question 2?"
    When I follow "Is this Deutsch question 1?"
    Then I should see "Is this Deutsch question 1?"
      And I should see "Yes, and this is Deutsch answer 1."
      And I should not see "Is this question 1?"
      And I should not see "Yes, and this is answer 1."
      And I should not see "Is this question 2?"
      And I should not see "Yes, and this is answer 2."
