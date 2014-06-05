@tags @users @tag_wrangling 
Feature: Tag Wrangling - Unsorted Tags
 
  Scenario: Editing an unsorted tag should not allow making it unwrangleable
    Given the following activated tag wrangler exists
      | login  |
      | Enigel |
      And basic tags
      And I am logged in as "Enigel"
      And I follow "Tag Wrangling"
      And a unsorted_tag exists with name: "author regrets nothing"
      # editing unsorted tag
    When I edit the tag "author regrets nothing"
    Then the "tag_unwrangleable" checkbox should be disabled

  Scenario: Sorting tags should keep you on the same page
    Given the following activated tag wrangler exists
      | login       |
      | dizmo       |
      And a fandom exists with name: "No Fandom", canonical: true
      And the unsorted tags setup
    When I am logged in as "dizmo"
      And I go to the unsorted_tags page
      And I follow "2"
      And I press "Update"
    Then I should see "2" within ".pagination span.current"
