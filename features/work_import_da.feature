@works
Feature: Import Works from deviantart
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from deviantart
  @import_da
  Scenario: Creating a new art work from an deviantart story with automatic metadata
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://bingeling.deviantart.com/art/Flooded-45971613"
    When I press "Import"
    Then I should see "Preview"
       And I should find "Flooded_by_bingeling.jpg" within "img[src]"
       And I should see "Digital Art" within "dd.freeform"
       And I should see "People" within "dd.freeform"
       And I should see "Vector" within "dd.freeform"
       And I should see "Published:2007-01-04"
       And I should see "Flooded" within "h2.title"
       And I should see "done with Photoshop 7" within "div.notes"
       And I should see "but they were definitely helpful" within "div.notes"
       And I should not see "deviant"
       And I should not see "bingeling"
       And I should not see "Visit the Artist"
       And I should not see "Download Image"
     When I press "Post"
     Then I should see "Work was successfully posted."
     When I am on cosomeone's user page
       #'
       Then I should see "Flooded"
  @import_da_fic
  Scenario: Creating a new fic from an deviantart
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://cesy12.deviantart.com/art/AO3-testing-text-196158032"
    When I press "Import"
    Then I should see "Preview"
       And I should see "Scraps" within "dd.freeform"
       And I should see "Published:2011-02-04"
       And I should see "AO3 testing text" within "h2.title"
       And I should see "This is the description of the story above." within "div.notes"
       And I should see "This is a text, like a story or something."
       And I should see "Complete with some paragraphs."
       And I should not see "deviant"
       And I should not see "cesy"
       And I should not see "AO3 testing text" within "#chapters"
       And I should not see "Visit the Artist"
       And I should not see "Download File"
     When I press "Post"
     Then I should see "Work was successfully posted."
     When I am on cosomeone's user page
       #'
       Then I should see "AO3 testing text"

