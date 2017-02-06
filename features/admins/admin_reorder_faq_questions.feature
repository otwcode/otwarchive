@admin
Feature: Admin Actions to re-order FAQs
  As an an admin
  I want to be able to re-order the FAQs

Scenario: Re-order the FAQs
  When I am logged in as an admin
  When I follow "Admin Posts"
    And I follow "Archive FAQ" within "#main"
  When I follow "New FAQ Category"
    And I should see "Since you don't have JavaScript"
    And I fill in "archive_faq_questions_attributes_0_question" with "What is AO3?"
    And I fill in "archive_faq_questions_attributes_0_content" with "Some text, that is sufficiently long to pass validation."
    And I fill in "Category name*" with "New subsection"
    And I fill in "archive_faq_questions_attributes_0_anchor" with "whatisao3"
  When I press "Post"
  Then I should see "ArchiveFaq was successfully created"
    And I follow "Edit"
    And I fill in "Questions:" with "3"
    And I press "Update Form"
    # Fill in data for the second question
    And I fill in "archive_faq_questions_attributes_1_question" with "This is a second question"
    And I fill in "archive_faq_questions_attributes_1_content" with "This is an answer to the second question"
    And I fill in "archive_faq_questions_attributes_1_anchor" with "whatisao32"
    # Fill in data for the third question
    And I fill in "archive_faq_questions_attributes_2_question" with "This is a third question"
    And I fill in "archive_faq_questions_attributes_2_content" with "This is an answer to the third question"
    And I fill in "archive_faq_questions_attributes_2_anchor" with "whatisao33"
  When I press "Post"
  Then I should see "ArchiveFaq was successfully updated"
  When I follow "Edit"
    And I follow "Reorder Questions"
    # First confirm the current order of the questions
    And I should see "1. What is AO3?"
    And I should see "2. This is a second question"
    And I should see "3. This is a third question"
    # Flip the order of the questions
    And I fill in "questions_1" with "3"
    And I fill in "questions_2" with "2"
    And I fill in "questions_3" with "1"
    And I press "Update Positions"
  When I follow "Edit"
    And I follow "Reorder Questions"
    # Confirm the questions are in the new reversed order
  Then I should see "1. This is a third question"
    And I should see "2. This is a second question"
    And I should see "3. What is AO3?"

