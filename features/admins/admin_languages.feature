Feature: Manipulate languages on the Archive
  In order to be multicultural
  As as an admin
  I'd like to be able to manipulate languages on the Archive

Scenario: Adding Abuse support for a language
  Given the following language exists
    | name        | short |
    | Arabic      | ar    |
  When I am logged in as an admin
    And I go to the languages page
    And I follow "Edit"
    And I check "Abuse support available"
    And I press "Update Language"
  When I follow "Report Abuse"
    And I should see "Arabic" within "select#abuse_report_language"


