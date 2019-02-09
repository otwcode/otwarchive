@series
Feature: Create and Edit Series
  In order to view series created by a user
  As a reader
  The index needs to load properly, even for authors with more than ArchiveConfig.ITEMS_PER_PAGE series

  Scenario: Creator manually enters a series name to add a work to a new series when the work is first posted
    Given I am logged in as "author"
      And I set up the draft "Sweetie Belle"
    When I fill in "work_series_attributes_title" with "Ponies"
    When I press "Post Without Preview"
    Then I should see "Part 1 of the Ponies series" within "div#series"
      And I should see "Part 1 of the Ponies series" within "dd.series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"

  Scenario: Creator selects an existing series name to add a work to an existing series when the work is first posted
    Given I am logged in as "author"
      And I post the work "Sweetie Belle" as part of a series "Ponies"
      And I set up the draft "Starsong"
    When I select "Ponies" from "work_series_attributes_id"
      And I press "Post Without Preview"
    Then I should see "Part 2 of the Ponies series" within "div#series"
      And I should see "Part 2 of the Ponies series" within "dd.series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"
      And I should see "Starsong"

  Scenario: Creator adds a work to an existing series by editing the work
    Given I am logged in as "author"
      And I post the work "Sweetie Belle" as part of a series "Ponies"
      And I post the work "Rainbow Dash"
    When I view the series "Ponies"
    Then I should not see "Rainbow Dash"
    When I edit the work "Rainbow Dash"
      And I select "Ponies" from "work_series_attributes_id"
      And I press "Post Without Preview"
    Then I should see "Part 2 of the Ponies series" within "div#series"
      And I should see "Part 2 of the Ponies series" within "dd.series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"
      And I should see "Rainbow Dash"

  Scenario: Works in a series have series navigation
    Given I am logged in as "author"
      And I post the work "Sweetie Belle" as part of a series "Ponies"
      And I post the work "Starsong" as part of a series "Ponies"
      And I post the work "Rainbow Dash" as part of a series "Ponies"
    When I view the series "Ponies"
      And I follow "Rainbow Dash"
    Then I should see "Part 3 of the Ponies series"
    When I follow "← Previous Work"
    Then I should see "Starsong"
    When I follow "← Previous Work"
    Then I should see "Sweetie Belle"
    When I follow "Next Work →"
    Then I should see "Starsong"

  Scenario: Creator can add series information
    Given I am logged in as "author"
      And I post the work "Sweetie Belle" as part of a series "Ponies"
    When I view the series "Ponies"
      And I follow "Edit Series"
      And I fill in "Series Description" with "This is a series about ponies. Of course"
      And I fill in "Series Notes" with "I wrote this under the influence of coffee! And pink chocolate."
      And I press "Update"
    Then I should see "Series was successfully updated."
      And I should see "This is a series about ponies. Of course" within "blockquote.userstuff"
      And I should see "I wrote this under the influence of coffee! And pink chocolate." within "dl.series"
      And I should see "Complete: No"
    When I follow "Edit Series"
      And I check "series_complete"
      And I press "Update"
    Then I should see "Complete: Yes"

  @disable_caching
  Scenario: A work can be in two series
    Given I am logged in as "author"
      And I post the work "Sweetie Belle" as part of a series "Ponies"
      And I post the work "Rainbow Dash" as part of a series "Ponies"
    When I edit the work "Rainbow Dash"
    Then the "series-options-show" checkbox should be checked
      And I should see "Ponies" within "fieldset#series-options"
    When I fill in "work_series_attributes_title" with "Black Beauty"
      And I press "Preview"
    Then I should see "Part 2 of the Ponies series" within "dd.series"
    When "AO3-3455" is fixed
      # And I should see "Part 1 of the Black Beauty series" within "dd.series"
    When I press "Update"
      And all indexing jobs have been run
    Then I should see "Part 1 of the Black Beauty series" within "dd.series"
      And I should see "Part 2 of the Ponies series" within "dd.series"
      And I should see "Part 1 of the Black Beauty series" within "div#series"
      And I should see "Part 2 of the Ponies series" within "div#series"

  Scenario: Creator with multiple pseuds adds a work to a new series when the work is first posted
    Given I am logged in as "author"
      And I add the pseud "Pointless Pseud"
      And I set up the draft "Sweetie Belle" using the pseud "Pointless Pseud"
    When I fill in "work_series_attributes_title" with "Ponies"
      And I press "Post Without Preview"
    Then I should see "Pointless Pseud"
      And I should see "Part 1 of the Ponies series" within "div#series"
      And I should see "Part 1 of the Ponies series" within "dd.series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"

  Scenario: Creator with multiple pseuds adds a work to an existing series when the work is first posted
    Given I am logged in as "author"
      And I add the pseud "Pointless Pseud"
      And I post the work "Sweetie Belle" as part of a series "Ponies" using the pseud "Pointless Pseud"
    When I set up the draft "Starsong" as part of a series "Ponies" using the pseud "Pointless Pseud"
      And I press "Post Without Preview"
    Then I should see "Pointless Pseud"
      And I should see "Part 2 of the Ponies series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"
      And I should see "Starsong"

  Scenario: Creator with multiple pseuds adds a work to an existing series by editing the work
    Given I am logged in as "author"
      And I add the pseud "Pointless Pseud"
      And I post the work "Sweetie Belle" as part of a series "Ponies" using the pseud "Pointless Pseud"
      And I post the work "Rainbow Dash" using the pseud "Pointless Pseud"
    When I view the series "Ponies"
    Then I should not see "Rainbow Dash"
    When I edit the work "Rainbow Dash"
      And I select "Ponies" from "work_series_attributes_id"
      And I press "Post Without Preview"
    Then I should see "Part 2 of the Ponies series" within "div#series"
      And I should see "Part 2 of the Ponies series" within "dd.series"
    When I view the series "Ponies"
    Then I should see "Sweetie Belle"
      And I should see "Rainbow Dash"

  Scenario: A pseud's series page contains the pseud in the page title
    Given I am logged in as "author"
      And I add the pseud "Pointless Pseud"
      And I post the work "Sweetie Belle" as part of a series "Ponies" using the pseud "Pointless Pseud"
    When I follow "Pointless Pseud"
      And I follow "Series (1)"
    Then the page title should include "by Pointless Pseud"

  @disable_caching
  Scenario: Rename a series
    Given I am logged in as a random user
    When I add the work "WALL-E" to series "Robots"
    Then I should see "Part 1 of the Robots series" within "div#series"
      And I should see "Part 1 of the Robots series" within "dd.series"
    When I view the series "Robots"
      And I follow "Edit Series"
      And I fill in "Series Title" with "Many a Robot"
      And I press "Update"
    Then I should see "Series was successfully updated."
      And I should see "Many a Robot"
    When I view the work "WALL-E"
    Then I should see "Part 1 of the Many a Robot series" within "div#series"
    And "AO3-3847" is fixed
    #  And I should see "Part 1 of the Many a Robot series" within "dd.series"

  Scenario: Post Without Preview
    Given I am logged in as "whoever" with password "whatever"
      And I add the work "public" to series "be_public"
    When I follow "be_public"
    Then I should not see the image "title" text "Restricted" within "h2"

  Scenario: View user's series index
    Given I am logged in as "whoever" with password "whatever"
      And I add the work "grumble" to series "polarbears"
    When I go to whoever's series page
    Then I should see "whoever's Series"
      And I should see "polarbears"

  Scenario: Series index for maaany series
    Given I am logged in as "whoever" with password "whatever"
      And I add the work "grumble" to "32" series "penguins"
    When I go to whoever's series page
    Then I should see "penguins30"
    When I follow "Next"
    Then I should see "penguins0"

  Scenario: Removing self as co-author from co-authored series
    Given I am logged in as "sun"
      And I set up the draft "Sweetie Bell" as part of a series "Ponies"
      And I add the co-author "moon"
      And I post the work without preview
    When I view the series "Ponies"
      And I wait 1 second
      And I follow "Remove Me As Author"
    Then I should see "You have been removed as an author from the series and its works."
    When "AO3-5083" is fixed
      # And "moon" should be the creator of the series "Ponies"
      # And "sun" should not be a creator on the series "Ponies"
    When I go to my works page
    Then I should not see "Sweetie Bell"

  Scenario: Delete a series
    Given I am logged in as "cereal" with password "yumyummy"
      And I add the work "Snap" to series "Krispies"
    When I view the series "Krispies"
      And I follow "Delete Series"
      And I press "Yes, Delete Series"
    Then I should see "Series was successfully deleted."

  Scenario: A work's series information is visible and up to date when previewing the work while posting or editing
    Given I am logged in as "author"
      And I add the pseud "Pointless Pseud"
      And I set up the draft "Sweetie Belle" as part of a series "Ponies"
    When I press "Preview"
    Then I should see "Part 1 of the Ponies series"
    When I press "Post"
      And I set up the draft "Rainbow Dash" as part of a series "Ponies" using the pseud "Pointless Pseud"
      And I press "Preview"
    Then I should see "Pointless Pseud"
      And I should see "Part 2 of the Ponies series"
    When I edit the work "Rainbow Dash"
      And I fill in "work_series_attributes_title" with "Black Beauty"
      And I press "Preview"
    Then I should see "Part 2 of the Ponies series" within "dd.series"
    When "AO3-3455" is fixed
    # And I should see "Part 1 of the Black Beauty series" within "dd.series"

  Scenario: When editing a series, the title field should not escape HTML
    Given I am logged in as "whoever"
      And I post the work "whatever" as part of a series "What a title! :< :& :>"
      And I go to whoever's series page
      And I follow "What a title! :< :& :>"
      And I follow "Edit Series"
    Then I should see "What a title! :< :& :>" in the "Series Title" input
