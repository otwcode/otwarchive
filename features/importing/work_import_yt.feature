@works
Feature: Import Works from yuletidtreasure
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from yuletidetreasure
  @import_yt
  Scenario: Creating a new work from an yuletidetreasure story with automatic metadata
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://yuletidetreasure.org/archive/75/commonplaces.html"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Sherlock Holmes" within "dd.fandom"
      And I should see "yuletide" within "dd.freeform"
      And I should see "BetaReject" within ".notes"
      And I should see "challenge:Yuletide 2008" within "dd.freeform"
      And I should see "Published:2008-12-25"
      And I should see "Commonplaces" within "h2.title"
      And I should see "With many many thanks to Cesca for brainstorming and to Terri for literally last-minute beta!" within "div.notes"
      And I should see "My life is spent in one long effort to escape from the commonplaces of existence."
      And I should see "I am ready to be incautious again."
      And I should not see the "alt" text "yuletide treasure"
      And I should not see "Quicksearch"
      And I should not see "Please post a comment on this story."
      And I should not see "Read posted comments."
      And I should not see "Fandom:" within "#chapters"
      And I should not see "Written for:" within "#chapters"
      And I should not see "With many many thanks" within "#chapters"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page
      #'
      Then I should see "Commonplaces"
  @import_yt_no_notes
  Scenario: Creating a new work from an yuletidetreasure story which doesn't have notes
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://yuletidetreasure.org/archive/12/quovadis.html"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Sherlock Holmes" within "dd.fandom"
      And I should see "yuletide" within "dd.freeform"
      And I should see "Rosemending" within ".notes"
      And I should see "challenge:Yuletide 2004" within "dd.freeform"
      And I should see "Published:2004-12-25"
      And I should see "Quo Vadis" within "h2.title"
      And I should see "Primum Non Nocere"
      And I should see "Terra Incognita: An unknown land."
      And I should not see the "alt" text "yuletide treasure"
      And I should not see "Quicksearch"
      And I should not see "Please post a comment on this story."
      And I should not see "Read posted comments."
      And I should not see "Fandom:" within "#chapters"
      And I should not see "Written for:" within "#chapters"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page
      #'
      Then I should see "Quo Vadis"


  @import_yt_ny
  Scenario: Creating a new work from an yuletidetreasure new year's resolution story
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://www.yuletidetreasure.org/archive/33/thebest.html"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Entourage (tv)" within "dd.fandom"
      And I should see "yuletide" within "dd.freeform"
      And I should see "shanalle" within ".notes"
      And I should see "challenge:NYR 2007" within "dd.freeform"
      And I should see "Published:2007-01-01"
      And I should see "The Best You Ever Had" within "h2.title"
      And I should see "Eric knew it was his own damn fault"
      And I should see "He's going to kill you."
      And I should not see the "alt" text "yuletide treasure"
      And I should not see "Quicksearch"
      And I should not see "Please post a comment on this story."
      And I should not see "Read posted comments."
      And I should not see "Fandom:" within "#chapters"
      And I should not see "Written for:" within "#chapters"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page
      #'
      Then I should see "The Best You Ever Had"

