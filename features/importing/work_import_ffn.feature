@works
Feature: Import Works from fanfiction.net
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from fanfiction.net
  @import_ffn
  Scenario: Importing a new work from an FFN story
    Given I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://www.fanfiction.net/s/3129674/1/What_More_Than_Usual_Light"
    When I press "Import"
    Then I should see "Sorry, Fanfiction.net does not allow imports from their site."

  @import_ffn_multi_chapter
  Scenario: Importing a new multichapter work from an FFN story
    Given I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://www.fanfiction.net/s/6646765/1/IChing"
    When I press "Import"
    Then I should see "Sorry, Fanfiction.net does not allow imports from their site."
