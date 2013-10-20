@tags @users @tag_wrangling

Feature: Tag Wrangling - Unsorted Tags

Scenario: unsorted wrangling

  Given the following activated tag wrangler exists
    | login  | password    |
    | Enigel | wrangulate! |
    And basic tags
    And I am logged in as "Enigel" with password "wrangulate!"
    And I follow "Tag Wrangling"

    And a unsorted_tag exists with name: "author regrets nothing"
  # editing unsorted tag
  When I edit the tag "author regrets nothing"
  Then the "tag_unwrangleable" checkbox should be disabled
