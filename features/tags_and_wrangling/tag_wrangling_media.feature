@tags @tag_wrangling
Feature: Media tags

  Scenario: Wranglers do not have the option to create media tags or change
  other tags to media tags
    Given I am logged in as a tag wrangler
    When I go to the new tag page
    Then I should not see "Media" within "#new_tag"
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
      And I choose "Media"
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
      And I choose "Media"
      And I press "Create Tag"
    Then I should see "Tag was successfully created."
      And the "New Media 2" tag should be canonical
      And the "New Media 2" tag should be a "Media" tag

  Scenario: Admins can recategorize tags into media tags
    Given a non-canonical fandom "Ambiguous Tag"
      And I am logged in as a "tag_wrangling" admin
    When I go to the "Ambiguous Tag" tag edit page
      And I select "Media" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Ambiguous Tag" tag should be a "Media" tag

  Scenario: Admins can recategorize media tags into other types
    Given a non-canonical media "Not A Media Anymore"
      And I am logged in as a "tag_wrangling" admin
    When I go to the "Not A Media Anymore" tag edit page
      And I select "Relationship" from "tag_type"
      And I press "Save changes"
    Then I should see "Tag was updated."
      And the "Not A Media Anymore" tag should be a "Relationship" tag

  Scenario: New media tags are added to the Fandoms header menu
    # Make sure the old state gets cached
    When I go to the homepage
    Then I should not see "New Media 3" within "#header .primary .dropdown .menu"
    When I create the canonical media tag "New Media 3"
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
    When I create the canonical media tag "New Media 3b"
      And I am logged out
    When I go to the homepage
    Then I should see "New Media 3b" within "#main .splash .browse"
    When I follow "New Media 3b" within "#main .splash .browse"
    Then I should see "Fandoms > New Media 3b"
      And I should see "No fandoms found"

  Scenario: New media tags are added to the Fandoms page
    Given I create the canonical media tag "New Media 4"
    When I go to the fandoms page
    Then I should see "New Media 4" within "#main .media"
    When I follow "New Media 4" within "#main .media"
    Then I should see "Fandoms > New Media 4"
      And I should see "No fandoms found"

  Scenario: Recategorizing a tag as media tag adds it to the Fandoms header menu and the Fandoms list on the homepage
    # Make sure the old state gets cached
    When I go to the homepage
    Then I should not see "Yet Another Media" within "#header .primary .dropdown .menu"
      And I should not see "Yet Another Media" within "#main .splash .browse"
    When I recategorize the "Yet Another Media" fandom as a "Media" tag
      And I am logged out
    When I go to the homepage
    Then I should see "Yet Another Media" within "#header .primary .dropdown .menu"
      And I should see "Yet Another Media" within "#main .splash .browse"

  Scenario: Recategorizing a media tag removes it from to the Fandoms header menu and the Fandoms list on the homepage
    Given a non-canonical media "Not a medium"
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

  Scenario: Renaming a media tag as admin changes it in the Fandoms header menu and the Fandoms list on the homepage
    Given a canonical media "New Mediia Tag"
      # Make sure the old state gets cached
      And I go to the homepage
    Then I should see "New Mediia Tag" within "#header .primary .dropdown .menu"
      And I should see "New Mediia Tag" within "#main .splash .browse"
    When I am logged in as a "tag_wrangling" admin
      And I edit the tag "New Mediia Tag"
    And I fill in "Name" with "New Media Tag"
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I am logged out
      And I go to the homepage
    Then I should see "New Media Tag" within "#header .primary .dropdown .menu"
      And I should see "New Media Tag" within "#main .splash .browse"

  @javascript
  Scenario: Wranglers can add media tags to fandoms and fandoms to media tags
    Given a canonical media "Big Media"
      And a canonical fandom "Great Fandom"
      And a canonical fandom "Greater Fandom"
      And I am logged in as a tag wrangler
      And I post the work "Some work" with fandom "Great Fandom"
      And I post the work "Some other work" with fandom "Greater Fandom"
    When I edit the tag "Great Fandom"
      And I choose "Big Media" from the "tag_media_string_autocomplete" autocomplete
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I edit the tag "Big Media"
      And I choose "Greater Fandom" from the "tag_fandom_string_autocomplete" autocomplete
      And I press "Save changes"
    Then I should see "Tag was updated."
    When I go to the "Big Media" fandoms page
    Then I should see "Great Fandom"
      And I should see "Greater Fandom"
