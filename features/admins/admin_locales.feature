@admin
Feature: Admin tasks

  Scenario: Add and edit a locale
  Given the following language exists
      | name       | short |
      | Dutch      | nl    |
  And I am logged in as an admin
  When I go to the locales page
  Then I should see "English (US)"
  When I follow "New Locale"
    And I select "Dutch" from "Language"
    And I fill in "locale_name" with "Dutch - Netherlands"
    And I fill in "locale_iso" with "nl-nl"
    And I check "Use this locale to send email"
    And I press "Create Locale"
  Then I should see "Dutch"
  When I follow "Edit"
    And I select "English" from "Language"
    And I fill in "locale_name" with "English (GB)"
    And I fill in "locale_iso" with "en-gb"
    And I check "Use this locale to send email"
    And I check "Use this locale for the interface"
    And I press "Update Locale"
  Then I should see "Your locale was successfully updated."
