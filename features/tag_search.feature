@no-txn @tags @tag_wrangling @search
Feature: Search Tags
  In order to find works in the archive
  As a user
  I want to search using tags

  Scenario: Search should search multiple types of tags
    Given The following tags exist
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | character    | searchable character                 |
      | relationship | searchable character/other character |
      And the tag indexes are updated
    When I search tags for "searchable"
    Then I can see the following tags
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | character    | searchable character                 |
      | relationship | searchable character/other character |

  Scenario: Search for fandom tag
    Given The fandom tag "searchable fandom" exists
      And the tag indexes are updated
    When I search for fandom tag "searchable fandom"
    Then I can see the fandom tag "searchable fandom"

  Scenario: Search for fandom tag should not show other types of tags
    Given The following tags exist
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | character    | searchable character                 |
      | relationship | searchable character/other character |
      And the tag indexes are updated
    When I search for fandom tag "searchable fandom"
    Then I can see the fandom tag "searchable fandom"
      And I cannot see the following tags
      | type         | tag                                  |
      | character    | searchable character                 |
      | relationship | searchable character/other character |

  Scenario: Search for canonical tags
    Given The canonical character "canonical character" exists
      And The following tags exist
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | relationship | searchable character/other character |
      And the tag indexes are updated
    When I search for canonical tag "canonical character"
    Then I can see the canonical tag "canonical character"
      And I cannot see the following tags
      | type         | tag                                  |
      | fandom       | searchable fandom                    |
      | relationship | searchable character/other character |

