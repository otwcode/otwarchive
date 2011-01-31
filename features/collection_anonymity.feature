@collections
Feature: Collection
  In order to run some fanfic festivals
  As a humble user
  I want to create a collection with anonymity and hidden-until-reveal works

  Scenario: Create a hidden collection, add new and existing works to it, reveal works

  Given the following activated users exist
    | login          | password    |
    | myname1        | something   |
    | myname2        | something   |
    | myname3        | something   |
    And basic tags
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Hidden Treasury"
  When I follow "New Collection"
    And I fill in "Display Title" with "Hidden Treasury"
    And I fill in "Collection Name" with "hidden_treasury"
    And I check "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully created"

  # Adding existing work to the collection without preview
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections/Challenges: " with "hidden_treasury"
    And I press "Post without preview"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
    And I should see "Old Snippet"
    
  # Post to collection without preview
  When I follow "Hidden Treasury"
    And I follow "Post To Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I press "Post without preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
    And I should see "myname1" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
  
  # Post to collection with preview
  When I follow "Hidden Treasury"
    And I follow "Post To Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "Another Snippet"
    And I fill in "content" with "This is another new snippet written for this hidden challenge"
    And I press "Preview"
  Then I should see "Collections: Hidden Treasury"
    And I should see "Draft was successfully created."
    And I should see "myname1" within ".byline"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "myname1" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
      
  When I follow "Hidden Treasury"
  Then I should see "New Snippet by myname1"
    And I should see "Old Snippet by myname1"
    And I should see "Another Snippet by myname1"
        
  When I follow "Log out"
  Then I should see "Mystery Work"
    And I should see "Part of Hidden Treasury"
  
  When I am logged in as "myname2" with password "something"
    And I go to the collections page
    And I follow "Hidden Treasury"
  Then I should see "Mystery Work"
    And I should see "Part of Hidden Treasury"
  
  # Reveal the collection
  When I follow "Settings"
    And I uncheck "Is this collection currently unrevealed?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"  
  # Works should no longer be hidden on the collection dashboard
    And I should not see "Mystery Work"
    And I should see "New Snippet by myname1"
    And I should see "Old Snippet by myname1"
    And I should see "Another Snippet by myname1"
    
  # Works should no longer say that they'll be revealed soon
  When I view the work "New Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is a new snippet written for this hidden challenge"
  When I view the work "Old Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "That could be an amusing crossover"
  When I view the work "Another Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is another new snippet written for this hidden challenge"
    
  # visitor should see all these works too
  When I follow "Log out"
    And I view the work "New Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is a new snippet written for this hidden challenge"
  When I view the work "Old Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "That could be an amusing crossover"
  When I view the work "Another Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is another new snippet written for this hidden challenge"
  
  # A third logged in user, not the author and not the owner, should see them too
  When I am logged in as "myname3" with password "something"
    And I view the work "New Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is a new snippet written for this hidden challenge"
  When I view the work "Old Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "That could be an amusing crossover"
  When I view the work "Another Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is another new snippet written for this hidden challenge"
  
  
  
  Scenario: Create an anonymous collection, add new and existing works to it, reveal authors
  
  Given the following activated users exist
    | login          | password    |
    | myname1        | something   |
    | myname2        | something   |
    And basic tags
    And I am logged in as "myname2" with password "something"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Anonymous Hugs"
  When I follow "New Collection"
    And I fill in "Display Title" with "Anonymous Hugs"
    And I fill in "Collection Name" with "anonyhugs"
    And I check "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully created"

  # Adding existing work to the collection without preview
  When I follow "Log out"
    And I am logged in as "myname1" with password "something"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections/Challenges: " with "anonyhugs"
    And I press "Post without preview"
  Then I should see "Old Snippet"
    And I should see "Collections: Anonymous Hugs"
    And I should not see "myname1" within ".byline"
    And I should see "Anonymous" within ".byline"
    
  # Post to collection without preview
  When I follow "Anonymous Hugs"
    And I follow "Post To Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I press "Post without preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
    And I should not see "myname1" within ".byline"
    And I should see "Anonymous" within ".byline"
    And I should see "Collections: Anonymous Hugs"
  
  # Post to collection with preview
  When I follow "Anonymous Hugs"
    And I follow "Post To Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "Another Snippet"
    And I fill in "content" with "This is another new snippet written for this hidden challenge"
    And I press "Preview"
  Then I should see "Collections: Anonymous Hugs"
    And I should see "Draft was successfully created."
    And I should not see "myname1" within ".byline"
    And I should see "Anonymous" within ".byline"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should not see "myname1" within ".byline"
    And I should see "Anonymous" within ".byline"
    And I should see "Collections: Anonymous Hugs"
      
  When I follow "Anonymous Hugs"
  Then I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
        
  When I follow "Log out"
  Then I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
  
  When I am logged in as "myname2" with password "something"
    And I go to the collections page
    And I follow "Anonymous Hugs"
  Then I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
  
  # Reveal the authors
  When I follow "Settings"
    And I uncheck "Is this collection currently anonymous?"
    And I press "Submit"
  Then I should see "Collection was successfully updated"  
  # Authors should no longer be hidden on the collection dashboard
    And I should not see "New Snippet by Anonymous"
    And I should see "New Snippet by myname1"
    And I should see "Old Snippet by myname1"
    And I should see "Another Snippet by myname1"
    
  # Works should have their authors in the view too
  When I view the work "New Snippet"
  Then I should see "myname1" within ".byline"
  When I view the work "Old Snippet"
  Then I should see "myname1" within ".byline"
  When I view the work "Another Snippet"
  Then I should see "myname1" within ".byline"
    
  # visitor should see all these works too
  When I follow "Log out"
    And I view the work "New Snippet"
  Then I should see "myname1" within ".byline"
  When I view the work "Old Snippet"
  Then I should see "myname1" within ".byline"
  When I view the work "Another Snippet"
  Then I should see "myname1" within ".byline"
  
  
  
  # Scenario: TODO Create a hidden and anonymous collection, add new and existing works to it, reveal works, then reveal authors
