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

  Scenario: Updating multiple tags works.
    Given I am logged in as a tag wrangler
      And the following typed tags exists
        | name                                   | type     |
        | Cowboy Bebop                           | Unsorted_tag |
        | Serial experiments lain                | Unsorted_tag |
        | Spike Spiegel                          | Unsorted_tag |
        | Annalise Keating & Bonnie Winterbottom | Unsorted_tag |
        | i love good omens                      | Unsorted_tag |
    When I go to the unsorted_tags page
     And I select "Fandom" for the unsorted tag "Cowboy Bebop"
     And I select "Fandom" for the unsorted tag "Serial experiments lain"
     And I select "Character" for the unsorted tag "Spike Spiegel"
     And I select "Relationship" for the unsorted tag "Annalise Keating & Bonnie Winterbottom"
     And I select "Freeform" for the unsorted tag "i love good omens"
     And I press "Update"
    Then I should see "Tags were successfully sorted"
     And the "Cowboy Bebop" tag should be a "Fandom" tag
     And the "Serial experiments lain" tag should be a "Fandom" tag
     And the "Spike Spiegel" tag should be a "Character" tag
     And the "Annalise Keating & Bonnie Winterbottom" tag should be a "Relationship" tag
     And the "i love good omens" tag should be a "Freeform" tag
