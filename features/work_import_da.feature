@works
Feature: Import Works from deviantart
  In order to have an archive full of works
  As an author
  I want to create new works by importing them from deviantart
  
  Scenario: Creating a new art work from an deviantart story with automatic metadata
    Given basic tags
      And the following activated user exists
        | login          | password    |
        | cosomeone      | something   |
      And I am logged in as "cosomeone" with password "something"
    When I go to the import page
      And I fill in "urls" with "http://bingeling.deviantart.com/art/Flooded-45971613"
    When I press "Import"
    Then I should see "Preview Work"
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


# TODO: import fic from DA
