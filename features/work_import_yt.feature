@works
Feature: Import Works from yuletidtreasure
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from yuletidetreasure
  
  Scenario: Creating a new work from an yuletidetreasure story with automatic metadata
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://yuletidetreasure.org/archive/75/commonplaces.html"
    When I press "Import"
    Then I should see "Preview Work"
      And I should see "Sherlock Holmes" within "dd.fandom"
      And I should see "yuletide" within "dd.freeform"
      And I should see "recipient:BetaReject" within "dd.freeform"
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
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page 
      #'
      Then I should see "Commonplaces"

