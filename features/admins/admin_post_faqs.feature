@admin
Feature: Admin Actions to Post FAQs
  As an an admin
  I want to be able to manage the archive FAQ

  Scenario: Post and edit a FAQ
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I am logged in as an admin
      And I follow "Admin Posts"
      And I follow "Archive FAQ" within "#header"
    Then I should not see "Some text"
    When I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
      And I press "Post"
    Then I should see "ArchiveFaq was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"
    When I follow "Edit"
      And I fill in "Answer*" with "New Content, yay"
      And I press "Post"
    Then I should see "New Content, yay"
      And I should not see "Some text"

  Scenario: Post a FAQ that is a translation of another
    Given basic languages
    When I am logged in as an admin
    When I follow "Admin Posts"
      And I follow "Archive FAQ" within "#header"
      And I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
    When I press "Post"
    Then I should see "ArchiveFaq was successfully created"

    When I follow "Archive FAQ"
      And I select "Deutsch" from "language_id"
      And I press "Go" within "div#inner.wrapper"
      And I follow "Edit"
      And I fill in "Question*" with "Was ist AO3?"
      And I fill in "Answer*" with "Einige Text, das ist lang genug, um die Überprüfung bestanden."
      And I fill in "Category name*" with "Neuer Abschnitt"
      And I check "Question translated"
      And I press "Post"
    Then I should see "ArchiveFaq was successfully updated."
      # The user has previously selected German as their language
      And I should not see "New subsection"
      And I should see "Neuer Abschnitt"
      And I should see "Was ist AO3?"
      And I should see "Einige Text"

    When I follow "Archive FAQ"
      And I select "English" from "language_id"
      And I press "Go" within "div#inner.wrapper"
    Then I should not see "Neuer Abschnitt"
    When I follow "New subsection"
      And I should see "What is AO3?"
      And I should see "Some text"
