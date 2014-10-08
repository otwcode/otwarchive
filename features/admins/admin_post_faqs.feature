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
    When I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"

  Scenario: Edit FAQ
    Given I have posted a FAQ
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I follow "Edit"
      And I fill in "Answer*" with "Number 1 posted FAQ, this is, and Yoda approves."
      And I press "Post"
    Then I should see "ArchiveFaq was successfully updated"
      And I should see "Yoda approves"
    When I go to the archive_faqs page
      And I follow "Edit"
      And I fill in "Answer*" with "New Content, yay"
      And I check "archive_faq_notify_translations"
      And I press "Post"
      And 1 email should be delivered

  Scenario: Post a FAQ that is a Translation of another
    Given basic languages
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#main"
      And I should not see "Some text"
    When I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"
      And 0 emails should be delivered

    

    # Now post a Translation of that FAQ
    # DISABLED UNTIL SOMEONE CAN FIGURE OUT HOW TO MAKE LANGUAGE SELECTION WORK
    And "Language Selection" is fixed
#    Given all emails have been delivered
#    When I follow "Archive FAQ"
#      And I choose "Deutsch" from "language_id"
#      And I press "Go" within "div#inner.wrapper"
#      And show me the page
#      And I should see "New subsection"
#      And I follow "Edit"
#      And I fill in "Question*" with "Was ist AO3?"
#      And I fill in "Answer*" with "Einige Text, das ist lang genug, um die Überprüfung bestanden."
#      And I fill in "Category name*" with "Neuer Abschnitt"
#      And I fill in "Anchor name*" with "wasistao3"
#      And I check "archive_faq_notify_translations"
#      And I press "Post"
#    Then I should see "ArchiveFaq was successfully updated."
#      And 1 email should be delivered
#
#    # The user has previously selected German as their language, lets make sure it persisted through Controller actions
#    Then I should see "Questions in the Neuer Abschnitt Category"
#      And I should not see "New subsection"
#      And I should see "Was ist AO3?"
#
#    # Toggle the languages at the top and see the correct data
#    When I follow "Archive FAQ"
#      And I select "English" from "language_id"
#      And I press "Go" within "div#inner.wrapper"
#    Then I should see "New subsection"
#      And I should not see "Neuer Abschnitt"
