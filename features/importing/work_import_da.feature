@works @import
Feature: Import Works from deviantart
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from deviantart

  Scenario: Creating a new art work from a deviantart title link with automatic metadata
    Given basic tags
      And I am logged in as "cosomeone"
    When I go to the import page
      And I fill in "urls" with "http://bingeling.deviantart.com/art/Flooded-45971613"
    When I press "Import"
    Then I should see "Preview"
      And I should see the image "src" text "http://orig03.deviantart.net/4707/f/2007/004/a/7/flooded_by_bingeling.jpg"
      And I should see "Digital Art" within "dd.freeform"
      And I should see "People" within "dd.freeform"
      And I should see "Vector" within "dd.freeform"
      And I should see "Published:2007-01-04"
      # Importer picks up artist name as title instead of actual title
      And I should not see "Flooded" within "h2.title"
      And I should see "bingeling" within "h2.title"
      And I should see "done with Photoshop 7" within "div.notes"
      And I should see "but they were definitely helpful" within "div.notes"
      And I should not see "deviant"
      And I should not see "Visit the Artist"
      And I should not see "Download Image"
     When I press "Post"
     Then I should see "Work was successfully posted."
     When I am on cosomeone's user page
     Then I should see "bingeling"

  Scenario: Creating a new art work from a deviantart gallery link fails - it needs the direct link
    Given basic tags
      And I am logged in as "cosomeone"
    When I go to the import page
      And I fill in "urls" with "http://bingeling.deviantart.com/gallery/#/drdbx9"
    When I press "Import"
    Then I should not see "Preview"
      And I should see "We were only partially able to import this work and couldn't save it. Please review below!"

  Scenario: Creating a new fic from deviantart import
    Given basic tags
      And I am logged in as "cosomeone"
    When I go to the import page
      And I fill in "urls" with "http://cesy12.deviantart.com/art/AO3-testing-text-196158032"
    When I press "Import"
    Then I should see "Preview"
      And I should see "Scraps"
      And I should see "Published:2011-02-04"
      # Importer picks up artist name as title instead of actual title
      And I should not see "AO3 testing text" within "h2.title"
      And I should see "cesy12" within "h2.title"
      And I should see "This is the description of the story above." within "div.notes"
      And I should see "This is a text, like a story or something."
      And I should see "Complete with some paragraphs."
      And I should not see "deviant"
      And I should not see "AO3 testing text" within "#chapters"
      And I should not see "Visit the Artist"
      And I should not see "Download File"
    When I press "Post"
    Then I should see "Work was successfully posted."
    When I am on cosomeone's user page
    Then I should see "cesy12"
