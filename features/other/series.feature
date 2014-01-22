@series
Feature: Create and Edit Series
  In order to view series created by a user
  As a reader
  The index needs to load properly, even for authors with more than ArchiveConfig.ITEMS_PER_PAGE series

  Scenario: Series information should appear in a work draft

  Given I am logged in as "author"
    And I set up the draft "Sweetie Belle"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Ponies"
    And I press "Preview"
  Then I should see "Part 1 of the Ponies series"
    And I should see "Draft was successfully created"
      
  Scenario: A work should be added to a new series
  
  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
  Then "Sweetie Belle" should be part 1 of the "Ponies" series

  Scenario: A work should be added to an existing series

  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
    And I add the work "Starsong" to the series "Ponies"
  Then "Starsong" should be part 2 of the "Ponies" series
  
  Scenario: A work can be added to a series after the fact
  
  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
    And I post the work "Rainbow Dash"
  Then "Rainbow Dash" should not be part of the "Ponies" series
  When I add the work "Rainbow Dash" to the series "Ponies"
  Then "Rainbow Dash" should be part 2 of the "Ponies" series
  
  Scenario: It should be possible to navigate between stories in a series
  
  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
    And I add the work "Starsong" to the series "Ponies"
    And I add the work "Rainbow Dash" to the series "Ponies"
    And I view the series "Ponies"
    And I follow "Rainbow Dash"
  Then I should see "Part 3 of the Ponies series"
  When I follow "«"
  Then I should see "Starsong"
  When I follow "«"
  Then I should see "Sweetie Belle"
  When I follow "»"
  Then I should see "Starsong"
  
  
  Scenario: I want to fill in series information 
  
  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
    And I add the work "Rainbow Dash" to the series "Ponies"
  When I view the series "Ponies"
    And I follow "Edit"
    And I fill in "Series Description" with "This is a series about ponies. Of course"
    And I fill in "Series Notes" with "I wrote this under the influence of coffee! And pink chocolate."
    And I press "Update"
  Then I should see "Series was successfully updated."
    And I should see "This is a series about ponies. Of course" within "blockquote.userstuff"
    And I should see "I wrote this under the influence of coffee! And pink chocolate." within "dl.series"
    And I should see "Complete: No"
  When I follow "Edit"
    And I check "series_complete"
    And I press "Update"
  Then I should see "Complete: Yes"


  Scenario: Adding a work to multiple series
  
  Given I am logged in as "author"
    And I add the work "Sweetie Belle" to the series "Ponies"
    And I add the work "Rainbow Dash" to the series "Ponies"  
    And I add the work "Rainbow Dash" to the series "Black Beauty"
  Then "Rainbow Dash" should be part 2 of the "Ponies" series
    And "Rainbow Dash" should be part 1 of the "Black Beauty" series  

    
  Scenario: Creating a series with a second pseud
  
  Given I am logged in as "author"
    And "author" creates the pseud "Pointless Pseud"
    And I set up the draft "Series Work"
    And I select "Pointless Pseud" from "work_author_attributes_ids_"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "Ponies"    
    And I press "Post Without Preview"
  Then "Series Work" should be part 1 of the "Ponies" series
    And the "Ponies" series should belong to the pseud "Pointless Pseud"

  Scenario: Rename a series
    Given I am logged in as a random user
    When I add the work "WALL-E" to series "Robots"
    Then I should see "Part 1 of the Robots series" within "div#series"
      And I should see "Part 1 of the Robots series" within "dd.series"
    When I view the series "Robots"
      And I follow "Edit"
      And I fill in "Series Title" with "Many a Robot"
      And I press "Update"
    Then I should see "Series was successfully updated."
      And I should see "Many a Robot"
    When I view the work "WALL-E"
      Then I should see "Part 1 of the Many a Robot series" within "div#series"
    # TODO: fix issue 3855
    #  And I should see "Part 1 of the Many a Robot series" within "dd.series"

  Scenario: Post Without Preview
    Given I am logged in as "whoever" with password "whatever"
      And I add the work "public" to series "be_public"
      And I follow "be_public"
      And "Issue 2169" is fixed
  # Then I should not see the "title" text "Restricted" within "h2"

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
