@tags @tag_wrangling
Feature: Media tags

  Scenario: Wranglers do not have the option to create media tags or change
  other tags to media tags
    Given I am logged in as a tag wrangler
    When I go to the new tag page
    Then I should not see "Medium" within "#new_tag"
    When I fill in "Name" with "Not A Media Tag"
      And I choose "Fandom"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Fandom" should be selected within "tag_type"
      # Make sure we can't see admin-only option
      And "Media" should not be an option within "tag_type"

  Scenario: Admins can create media tags and then make them canonical
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "New Media 1"
      And I choose "Medium"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Media" should be selected within "tag_type"
      # Make sure we can see regular wrangling option
      And "Fandom" should be an option within "tag_type"
    When I check "Canonical"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "New Media 1" tag should be canonical
      And the "New Media 1" tag should be a "Media" tag

  Scenario: Admins can create canonical media tags
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "New Media 2"
      And I check "Canonical"
      And I choose "Medium"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And the "New Media 2" tag should be canonical
      And the "New Media 2" tag should be a "Media" tag

  Scenario: Admins can recategorize tags into media tags
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "Ambiguous Tag"
      And I choose "Fandom"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Fandom" should be selected within "tag_type"
    When I select "Media" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Ambiguous Tag" tag should be a "Media" tag

  Scenario: Admins can recategorize tags into other types
    Given I am logged in as a "tag_wrangling" admin
    When I go to the new tag page
      And I fill in "Name" with "Not A Medium Anymore"
      And I choose "Medium"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And "Media" should be selected within "tag_type"
    When I select "Relationship" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Not A Medium Anymore" tag should be a "Relationship" tag

  Scenario: New media tags are added to the Fandoms header menu
    # Make sure the old state gets cached
    When I go to the homepage
    Then I should not see "New Media 3" within "#header .primary .dropdown .menu"
    When I have just created the canonical media tag "New Media 3"
      And I am logged out
    When I go to the homepage
    Then I should see "New Media 3" within "#header .primary .dropdown .menu"
    When I follow "New Media 3" within "#header .primary .dropdown .menu"
    Then I should see "Fandoms > New Media 3"
      And I should see "No fandoms found"

  Scenario: New media tags are added to the Fandoms list on the homepage
    # Make sure the old state gets cached
    Given I go to the homepage
    Then I should not see "New Media 3b" within "#main .splash .browse"
    When I have just created the canonical media tag "New Media 3b"
      And I am logged out
    When I go to the homepage
    Then I should see "New Media 3b" within "#main .splash .browse"
    When I follow "New Media 3b" within "#main .splash .browse"
    Then I should see "Fandoms > New Media 3b"
      And I should see "No fandoms found"

  Scenario: New media tags are added to the Fandoms page
    Given I have just created the canonical media tag "New Media 4"
    When I go to the fandoms page
    Then I should see "New Media 4" within "#main .media"
    When I follow "New Media 4" within "#main .media"
    Then I should see "Fandoms > New Media 4"
      And I should see "No fandoms found"

  Scenario: Recategorizing a tag as media tag adds it to the Fandoms header menu
    # Make sure the old state gets cached
    When I go to the homepage
    Then I should not see "Yet Another Medium" within "#header .primary .dropdown .menu"
    When I have just recategorized the "Yet Another Medium" fandom as a "Media" tag
      And I am logged out
    When I go to the homepage
    Then I should see "Yet Another Medium" within "#header .primary .dropdown .menu"

  Scenario: Recategorizing a tag as media tag adds it to the Fandoms list on the homepage
    # Make sure the old state gets cached
    When I go to the homepage
    Then I should not see "Yet Another Medium" within "#main .splash .browse"
    When I have just recategorized the "Yet Another Medium" fandom as a "Media" tag
      And I am logged out
    When I go to the homepage
    Then I should see "Yet Another Medium" within "#main .splash .browse"

  Scenario: Recategorizing a media tag removes it from to the Fandoms header menu and the Fandoms list on the homepage
    Given the non-canonical media "Not a medium"
      # Make sure the old state gets cached
      And I go to the homepage
    Then I should see "Not a medium" within "#header .primary .dropdown .menu"
      And I should see "Not a medium" within "#main .splash .browse"
    When I am logged in as a "tag_wrangling" admin
      And I edit the tag "Not a medium"
      And I select "Character" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Not a medium" tag should be a "Character" tag
    When I am logged out
      And I go to the homepage
    Then I should not see "Not a medium" within "#header .primary .dropdown .menu"
      And I should not see "Not a medium" within "#main .splash .browse"

  @javascript
  Scenario: Wranglers can add fandoms to new media tags
    Given I have just created the canonical media tag "New Media 5"
      And a canonical fandom "Great Fandom"
      And I am logged in as a tag wrangler
      And I post the work "Some Work" with fandom "Great Fandom"
    When I edit the tag "Great Fandom"
      And I choose "New Media 5" from the "tag_media_string_autocomplete" autocomplete
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I go to the "New Media 5" fandoms page
    Then I should see "Great Fandom"

  @javascript
  Scenario: Wranglers can add fandoms to new media tags on the medium's tag page
    Given I have just created the canonical media tag "New Media 6"
      And a canonical fandom "Great Fandom"
     And I am logged in as a tag wrangler
      And I post the work "Some Work" with fandom "Great Fandom"
    When I edit the tag "New Media 6"
      And I choose "Great Fandom" from the "tag_fandom_string_autocomplete" autocomplete
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I go to the "New Media 6" fandoms page
    Then I should see "Great Fandom"
