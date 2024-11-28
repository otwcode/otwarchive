@admin
Feature: Admin Actions to Post FAQs
  As an an admin
  I want to be able to manage the archive FAQ

  Scenario Outline: Authorized admin posts, edits and deletes a FAQ category
    When I go to the archive_faqs page
    Then I should see "Some commonly asked questions about the Archive are answered here"
      And I should not see "Some text"
    When I am logged in as a "<role>" admin
      And I follow "Admin Posts"
      And I follow "Archive FAQ" within "#header"
    Then I should not see "Some text"
    When I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
      And I press "Post"
    Then I should see "Archive FAQ was successfully created"
    When I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "Some text, that is sufficiently long to pass validation" within ".userstuff"
    When I follow "Edit"
      And I fill in "Answer*" with "New Content, yay"
      And I press "Post"
    Then I should see "New Content, yay"
      And I should not see "Some text"
    When I go to the archive_faqs page
      And I follow "Delete"
    Then I should see "Are you sure you want to delete the FAQ Category"
    When I press "Yes, Delete FAQ Category"
    Then I should not see "New subsection"

    Examples:
      | role       |
      | support    |
      | superadmin |
      | docs       |

  @javascript
  Scenario Outline: Authorized admin deletes a FAQ question
    Given 1 Archive FAQ with 1 question exists
      And I am logged in as a "<role>" admin
      And I go to the archive_faqs page
      And I follow "Edit"
      And I follow "Remove Question"
      And I press "Post"
    Then I should see "Archive FAQ was successfully updated."
      And I should see "We're sorry, there are currently no entries in this category."

    Examples:
      | role       |
      | support    |
      | superadmin |
      | docs       |

  Scenario: Post a translated FAQ for a locale, then change the locale's code.
    Given basic languages
      And I am logged in as a "superadmin" admin

    # Post "en" FAQ
    When I go to the archive_faqs page
      And I follow "New FAQ Category"
      And I fill in "Question*" with "What is AO3?"
      And I fill in "Answer*" with "Some text, that is sufficiently long to pass validation."
      And I fill in "Category name*" with "New subsection"
      And I fill in "Anchor name*" with "whatisao3"
      And I press "Post"
    Then I should see "Archive FAQ was successfully created"

    # Translate FAQ to "de"
    When I am logged in as a "translation" admin
      And I follow "Admin Posts"
      And I follow "Archive FAQ"
      And I select "Deutsch" from "Language:"
      And I press "Go" within "div#inner.wrapper"
      And I follow "Edit"
      And I fill in "Question*" with "Was ist AO3?"
      And I fill in "Answer*" with "Einiger Text, der lang genug ist, um die Überprüfung zu bestehen."
      And I fill in "Category name*" with "Neuer Abschnitt"
      And I check "Question translated"
      And I press "Post"
    Then I should see "Archive FAQ was successfully updated."
      And I should not see "New subsection"
      And I should see "Neuer Abschnitt"
      And I should see "Was ist AO3?"
      And I should see "Einiger Text"

    # Change locale "de" to "ger"
    When I go to the locales page
      And I follow "Edit"
    Then I should see "Deutsch" in the "Name" input
    When I fill in "locale_iso" with "ger"
      And I press "Update Locale"
    Then I should see "Your locale was successfully updated."
      And I should see "Deutsch ger"

    # The session preference is "de", which no longer exists; the default locale should be used
    When I go to the archive_faqs page
    Then "English (US)" should be selected within "Language:"

    # Log out and view FAQs; the default locale should be used
    When I log out
      And I go to the archive_faqs page
      And I follow "New subsection"
    Then I should see "What is AO3?"
      And I should see "Some text"

    # Select "ger"
    When I go to the archive_faqs page
      And I select "Deutsch" from "Language:"
      And I press "Go" within "div#inner.wrapper"
      And I follow "Neuer Abschnitt"
    Then I should see "Was ist AO3?"
      And I should see "Einiger Text"

  Scenario: Links to create, reorder and delete FAQ categories are not shown for non-English language FAQs
    Given basic languages
      And 1 Archive FAQ exists
      And I am logged in as a "superadmin" admin
    When I go to the archive_faqs page
    Then I should see "New FAQ Category"
      And I should see "Reorder FAQs"
      And I should see "Delete"
      And I should see "Edit"
    When I select "Deutsch" from "Language:"
      And I press "Go" within "div#inner.wrapper"
    Then I should not see "New FAQ Category"
      And I should not see "Reorder FAQs"
      And I should not see "Delete"
      But I should see "Edit"

  @javascript
  Scenario: Links to add, reorder and remove FAQ questions are not shown for non-English language FAQs
    Given basic languages
      And 1 Archive FAQ with 1 question exists
      And I am logged in as a "superadmin" admin
    When I go to the archive_faqs page
      And I follow "Edit"
    Then I should see "Reorder Questions"
      And I should see "Remove Question"
      And I should see "Add Question"
      But I should not see "Question translated"
    When I select "Deutsch" from "Language:"
      And I press "Go" within "div#inner.wrapper"
      And I follow "Edit"
    Then I should not see "Reorder Questions"
      And I should not see "Remove Question"
      And I should not see "Add Question"
      But I should see "Question translated"

  Scenario: Translation admins do not see links to edit English language FAQs
    Given basic languages
      And 1 Archive FAQ exists
      And I am logged in as a "translation" admin
    When I go to the archive_faqs page
    Then I should not see "Edit"
      And I should not see "New FAQ Category"
      And I should not see "Reorder FAQs"
      And I should not see "Delete"
    When I follow "Show"
    Then I should not see "Edit" within ".header"
      But I should see "Updated:" within ".header"
    When I go to the archive_faqs page
      And I select "Deutsch" from "Language:"
      And I press "Go" within "div#inner.wrapper"
    Then I should see "Edit"
      And I should not see "New FAQ Category"
      And I should not see "Reorder FAQs"
      And I should not see "Delete"
    When I follow "Show"
    Then I should see "Edit" within ".header"
      And I should see "Updated:" within ".header"

  Scenario Outline: Links to create and edit FAQs are not shown to unauthorized admins
    Given an archive FAQ category with the title "Very important FAQ" exists
      And I am logged in as a "<role>" admin
    When I follow "Admin Posts"
    Then I should not see "Archive FAQ" within "#header"
    When I go to the archive_faqs page
    Then I should not see "Edit"
      And I should not see "New FAQ Category"
      And I should not see "Reorder FAQs"
      And I should not see "Delete"
      But I should see "Available Categories"
    When I follow "Very important FAQ"
    Then I should not see "Edit"
      And I should not see "Updated:"

    Examples:
      | role                       |
      | board                      |
      | board_assistants_team      |
      | communications             |
      | development_and_membership |
      | elections                  |
      | legal                      |
      | tag_wrangling              |
      | policy_and_abuse           |
      | open_doors                 |
