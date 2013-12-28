@collections
Feature: Collection
  In order to run some fanfic festivals
  As a humble user
  I want to create a collection with anonymity and hidden-until-reveal works

  Scenario: Create a hidden collection, add new and existing works to it, reveal works

  Given basic tags
    And I am logged in as "first_user"
    And I am logged in as "second_user"
    And I go to first_user's user page
    And I press "Subscribe"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Hidden Treasury"
  When I follow "New Collection"
    And I fill in "Display Title" with "Hidden Treasury"
    And I fill in "Collection Name" with "hidden_treasury"
    And I check "This collection is unrevealed"
    And I submit
  Then I should see "Collection was successfully created"

  # Adding existing work to the collection without preview
  When I am logged in as "first_user"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "hidden_treasury"
    And I press "Post Without Preview"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
    And I should see "Old Snippet"
    
  # Post to collection without preview
  # Also check that subscription notices don't go out
  Given all emails have been delivered
  When I follow "Hidden Treasury"
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I press "Post Without Preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
    And I should see "first_user" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
    And 0 emails should be delivered
  
  # Post to collection with preview
  When I follow "Hidden Treasury"
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "Another Snippet"
    And I fill in "content" with "This is another new snippet written for this hidden challenge"
    And I press "Preview"
  Then I should see "Collections: Hidden Treasury"
    And I should see "Draft was successfully created."
    And I should see "first_user" within ".byline"
  When I press "Post"
  Then I should see "Work was successfully posted"
    And I should see "first_user" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Collections: Hidden Treasury"
    And 0 emails should be delivered
      
  When I follow "Hidden Treasury"
  Then I should see "New Snippet by first_user"
    And I should see "Old Snippet by first_user"
    And I should see "Another Snippet by first_user"
    
  # bookmark a hidden work
  When I follow "Another Snippet"
    And I follow "Bookmark"
    And I fill in "bookmark_notes" with "I liked this story"
    And I press "Create"
  Then I should see "Bookmark was successfully created"
  
  # make it part of a series where the rest aren't secret
  When I post the work "Part b"
    And I edit the work "Part b"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "New series"
    And I press "Post Without Preview"
        
  When I log out
    And I go to "Hidden Treasury" collection's page
  Then I should see "Mystery Work"
    And I should see "Part of Hidden Treasury"
  When I go to the bookmarks page
  Then I should see "List of Bookmarks"
    And I should see "Mystery Work"
    And I should not see "Another Snippet"
  
  When I am logged in as "second_user"
    And I go to the collections page
    And I follow "Hidden Treasury"
  Then I should see "Mystery Work"
    And I should see "Part of Hidden Treasury"
    And I should not see "Old Snippet"
    And I should not see "Another Snippet"
    And I should not see "New Snippet"
    And I should not see "first_user"
  
  # Reveal the collection
  When I follow "Settings"
    And I uncheck "This collection is unrevealed"
    And I press "Update"
  Then I should see "Collection was successfully updated"  
  # Works should no longer be hidden on the collection dashboard
    And I should not see "Mystery Work"
    And I should see "New Snippet by first_user"
    And I should see "Old Snippet by first_user"
    And I should see "Another Snippet by first_user"
    
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
  When I log out
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
  When I am logged in as "third_user"
    And I view the work "New Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is a new snippet written for this hidden challenge"
  When I view the work "Old Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "That could be an amusing crossover"
  When I view the work "Another Snippet"
  Then I should not see "This work is part of an ongoing challenge and will be revealed soon"
    And I should see "This is another new snippet written for this hidden challenge"
  
  # bookmark should now be revealed
  When I go to the bookmarks page
  Then I should see "List of Bookmarks"
    And I should not see "Mystery Work"
    And I should see "Another Snippet"
  
  Scenario: Create an anonymous collection, add new and existing works to it, reveal authors
  
  Given basic tags
    And I am logged in as "second_user"
  When I go to the collections page
    And I follow "New Collection"
    And I fill in "Display Title" with "Anonymous Hugs"
    And I fill in "Collection Name" with "anonyhugs"
    And I check "This collection is anonymous"
    And I submit
  Then I should see "Collection was successfully created"

  # Adding existing work to the collection without preview
  When I am logged in as "first_user"
    And I post the work "Old Snippet"
    And I edit the work "Old Snippet"
    And I fill in "Post to Collections / Challenges" with "anonyhugs"
    And I press "Post Without Preview"
  Then I should see "Old Snippet"
    And I should see "Collections: Anonymous Hugs"
  When I log out
    And I go to "Anonymous Hugs" collection's page
  Then I should not see "first_user"
    And I should see "by Anonymous"
    
  # Post to collection without preview
  When I am logged in as "first_user"
    And I go to "Anonymous Hugs" collection's page
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I press "Post Without Preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
  When I log out
    And I go to "Anonymous Hugs" collection's page
  Then I should not see "first_user"
    And I should see "by Anonymous"
  
  # Post to collection with preview
  When I am logged in as "first_user"
    And I go to "Anonymous Hugs" collection's page
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "Another Snippet"
    And I fill in "content" with "This is another new snippet written for this hidden challenge"
    And I press "Preview"
  Then I should see "Collections: Anonymous Hugs"
    And I should see "Draft was successfully created."
    And I should see "Anonymous" within ".byline"
  When I press "Post"
  Then I should see "Work was successfully posted"
  When I log out
    And I go to "Anonymous Hugs" collection's page
  Then I should not see "first_user"
    And I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
    
  # bookmark an anonymous work
  When I am logged in as "second_user"
    And I go to "Anonymous Hugs" collection's page
    And I follow "Another Snippet"
    And I follow "Bookmark"
    And I fill in "bookmark_notes" with "I liked this story"
    And I press "Create"
  Then I should see "Bookmark was successfully created"
  
  # make it part of a series where the rest aren't secret
  When I am logged in as "first_user"
    And I post the work "Part b"
    And I edit the work "Part b"
    And I check "series-options-show"
    And I fill in "work_series_attributes_title" with "New series"
    And I press "Post Without Preview"
    And I edit the work "Another Snippet"
    And I check "series-options-show"
    And I select "New series" from "work_series_attributes_id"
    And I press "Post Without Preview"
  Then I should see "Part 2 of the New series series"
        
  When I log out
    And I go to "Anonymous Hugs" collection's page
  Then I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
  When I go to the bookmarks page
  Then I should see "List of Bookmarks"
    And I should see "Another Snippet by Anonymous"
  
  When I am logged in as "second_user"
    And I go to the collections page
    And I follow "Anonymous Hugs"
  Then I should see "New Snippet by Anonymous"
    And I should see "Old Snippet by Anonymous"
    And I should see "Another Snippet by Anonymous"
    
  # check the series
  When I follow "Another Snippet"
    And I follow "New series"
    And "Issue 1253" is fixed
  Then I should see "Anonymous"
    # And I should not see "first_user"
  
  # Reveal the authors
  When I go to "Anonymous Hugs" collection's page
    And I follow "Settings"
    And I uncheck "This collection is anonymous"
    And I press "Update"
  Then I should see "Collection was successfully updated"  
  # Authors should no longer be hidden on the collection dashboard
    And I should not see "New Snippet by Anonymous"
    And I should see "New Snippet by first_user"
    And I should see "Old Snippet by first_user"
    And I should see "Another Snippet by first_user"
    
  # Works should have their authors in the view too
  When I view the work "New Snippet"
  Then I should see "first_user" within ".byline"
  When I view the work "Old Snippet"
  Then I should see "first_user" within ".byline"
  When I view the work "Another Snippet"
  Then I should see "first_user" within ".byline"
    
  # visitor should see all these works too
  When I log out
    And I view the work "New Snippet"
  Then I should see "first_user" within ".byline"
  When I view the work "Old Snippet"
  Then I should see "first_user" within ".byline"
  When I view the work "Another Snippet"
  Then I should see "first_user" within ".byline"
  
  # bookmark should now be revealed
  When I go to the bookmarks page
  Then I should see "List of Bookmarks"
    And I should see "Another Snippet by first_user"
    And I should not see "Another Snippet by Anonymous"
  
  # Scenario: TODO Create a hidden and anonymous collection, add new and existing works to it, reveal works, then reveal authors
  # Isn't this partially covered by challenge_yuletide? Probably better to expand that.
  
  Scenario: Create a hidden collection, reveal works gradually by day, like purimgifts
  
  Given the following activated users exist
    | login          | password    |
    | first_user        | something   |
    | second_user        | something   |
    | third_user        | something   |
    And basic tags
    And I am logged in as "second_user"
    And I go to first_user's user page
    And I press "Subscribe"
  When I go to the collections page
  Then I should see "Collections in the "
    And I should not see "Hidden Treasury"
  When I follow "New Collection"
    And I fill in "Display Title" with "Hidden Treasury"
    And I fill in "Collection Name" with "hidden_treasury"
    And I check "This collection is unrevealed"
    And I submit
  Then I should see "Collection was successfully created"
  
  # post to collection for day 1
  When I log out
    And I am logged in as "first_user"
  Given all emails have been delivered
  When I go to "Hidden Treasury" collection's page
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I fill in "Additional Tags" with "Purim Day 1"
    And I press "Post Without Preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
    And I should see "first_user" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Purim Day 1"
    And I should see "Collections: Hidden Treasury"
    And 0 emails should be delivered
    
  # post to collection for day 2
  When I follow "Hidden Treasury"
    And I follow "Post to Collection"
    And I fill in "Fandoms" with "No Fandom"
    And I fill in "Work Title" with "New Snippet 2"
    And I fill in "content" with "This is a new snippet written for this hidden challenge"
    And I fill in "Additional Tags" with "Purim Day 2"
    And I press "Post Without Preview"
  Then I should see "New Snippet"
    And I should see "Work was successfully posted"
    And I should see "first_user" within ".byline"
    And I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should see "Purim Day 2"
    And I should see "Collections: Hidden Treasury"
    And 0 emails should be delivered
    
  # fics are both hidden
  When I log out
    And I am logged in as "third_user"
  When I view the work "New Snippet"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should not see "Purim Day 1"
  When I view the work "New Snippet 2"
  Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
    And I should not see "Purim Day 2"
    
  # mod views fics
  When I am logged in as "second_user"
    And I go to "Hidden Treasury" collection's page
    And I follow "Manage Items"
    And I follow "Approved"
  Then I should see "Items in Hidden Treasury"
    And I should see "first_user"
  # TODO: Fix a way of referring to these buttons
  #When I check "unreveal_15261"
  #  And I press "submit_15261"
  When "Issue 2241" is fixed
  # Then 1 email should be delivered
    
  # first fic now visible, second still not
  #When I log out
  #  And I am logged in as "third_user"
  #When I view the work "New Snippet"
  #Then I should not see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
  #  And I should see "Purim Day 1"
  #When I view the work "New Snippet 2"
  #Then I should see "This work is part of an ongoing challenge and will be revealed soon! You can find details here: Hidden Treasury"
  #  And I should not see "Purim Day 2"
