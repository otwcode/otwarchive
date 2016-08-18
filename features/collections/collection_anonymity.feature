@collections
Feature: Collection
  In order to run some fanfic festivals
  As a humble user
  I want to create a collection with anonymity and hidden-until-reveal works

  Scenario: Works in a hidden collection should be visible to the mod and author but not other users
    Given I have the hidden collection "Hidden Treasury"
    When I am logged in as "first_user"
      And I set up the draft "Old Snippet" in collection "Hidden Treasury"
      And I press "Preview"    
    Then I should see "Collections: Hidden Treasury"
      And I should see "Draft was successfully created."
    When I press "Post"
    Then the work "Old Snippet" should be visible to me
      And I should see "part of an ongoing challenge"
    When I am logged in as "moderator"
    Then the work "Old Snippet" should be visible to me
      And I should see "part of an ongoing challenge"
    When I am logged in as "second_user"
    Then the work "Old Snippet" should be hidden from me
    When I am logged out
    Then the work "Old Snippet" should be hidden from me
  
  Scenario: The moderator can reveal all the works in a hidden collection
    Given I have the hidden collection "Hidden Treasury"
      And "second_user" subscribes to author "first_user"
      And the user "third_user" exists and is activated
      And all emails have been delivered
    When I am logged in as "first_user"
      And I post the work "New Snippet" to the collection "Hidden Treasury" as a gift for "third_user"
      And subscription notifications are sent
    Then 0 emails should be delivered
    When I reveal works for "Hidden Treasury"
    Then "third_user" should be emailed
      # not anonymous
      And the email to "third_user" should contain "first_user"
    When subscription notifications are sent
      And "AO3-4367: author subscribers not notified when works revealed" is fixed
    #Then "second_user" should be emailed
    #  And the email to "second_user" should contain "first_user"
    When I am logged out
    Then the work "New Snippet" should be visible to me
    When I view the collection "Hidden Treasury"
    Then I should see "New Snippet"
      And I should not see "Mystery Work"
    When I am logged in as "second_user"
    Then the work "New Snippet" should be visible to me
    When I view the collection "Hidden Treasury"
    Then I should see "New Snippet"
      And I should not see "Mystery Work"
      
  Scenario: The moderator can reveal a single work in a hidden collection
    Given I have the hidden collection "Hidden Treasury"
      And "second_user" subscribes to author "first_user"
      And the user "third_user" exists and is activated
      And the user "fourth_user" exists and is activated
      And all emails have been delivered
    When I am logged in as "first_user"
      And I post the work "First Snippet" to the collection "Hidden Treasury" as a gift for "third_user"
      And I post the work "Second Snippet" to the collection "Hidden Treasury" as a gift for "fourth_user"
      And subscription notifications are sent
    Then 0 emails should be delivered
    When I am logged in as "moderator"
      And I view the approved collection items page for "Hidden Treasury"
      # items listed in date order so checking the second will reveal the older work
      And I uncheck the 2nd checkbox with id matching "collection_items_\d+_unrevealed"
      And I submit
    Then "fourth_user" should not be emailed
    When "AO3-2240: gift notifications not sent for individual reveals" is fixed
    # Then "third_user" should be emailed
    #   And the email to "third_user" should contain "first_user"
    When subscription notifications are sent
      And "AO3-4367: author subscribers not notified when works revealed" is fixed
    # Then "second_user" should be emailed
    #   And 1 emails should be delivered
    #   And the email to "second_user" should contain "first_user"
    #   And the email to "second_user" should contain "First Snippet"
    #   And the email to "second_user" should not contain "Second Snippet"
    When I am logged out
    Then the work "First Snippet" should be visible to me
      And the work "Second Snippet" should be hidden from me
    When I view the collection "Hidden Treasury"
    Then I should see "First Snippet"
    
  Scenario: Bookmarks for hidden works should not reveal the work to others
    Given I have the hidden collection "Hidden Treasury"
      And I am logged in as "first_user"
      And I post the work "Hiding Work" to the collection "Hidden Treasury"
    When I am logged in as "moderator"
      And I bookmark the work "Hiding Work"
    When I am logged out
      And I go to the bookmarks page
    Then I should see "List of Bookmarks"
      And I should see "Mystery Work"
      And I should not see "Hiding Work"
    When I reveal works for "Hidden Treasury"
      And I am logged out
      And I go to the bookmarks page
    Then I should not see "Mystery Work"
      And I should see "Hiding Work"
    
  Scenario: The authors in an anonymous collection should only be visible to themselves and admins
    Given I have the anonymous collection "Anonymous Hugs"
      And I am logged in as "first_user"
      And I post the work "Old Snippet" to the collection "Anonymous Hugs"
      And all search indexes are updated
    When I view the work "Old Snippet"
    Then the author of "Old Snippet" should be visible to me on the work page
    When I am logged out
    Then the author of "Old Snippet" should be hidden from me
    When I am logged in as "second_user"
    Then the author of "Old Snippet" should be hidden from me
    When I am logged in as an admin
    Then the author of "Old Snippet" should be visible to me on the work page
    # special case for moderator: can't see name on the work (to avoid unwanted spoilers)
    # but can see names + titles on in the collection items management area
    When I am logged in as "moderator"
    Then the author of "Old Snippet" should be hidden from me
    When I view the approved collection items page for "Anonymous Hugs"
    Then I should see "Old Snippet"
      And I should see "first_user"
  
  Scenario: Bookmarks should not reveal the authors of anonymous works
    Given I have the anonymous collection "Anonymous Hugs"
      And I am logged in as "first_user"
      And I post the work "Old Snippet" to the collection "Anonymous Hugs"
      And all search indexes are updated
    When I am logged in as "second_user"
      And I bookmark the work "Old Snippet"
      And I go to the bookmarks page
    Then I should see "Old Snippet by Anonymous"
      And I should not see "first_user"

  Scenario: The moderator can reveal all the authors in an anonymous collection
    Given I have the anonymous collection "Anonymous Hugs"
      And "second_user" subscribes to author "first_user"
      And the user "third_user" exists and is activated
      And all emails have been delivered      
    When I am logged in as "first_user"
      And I post the work "Old Snippet" to the collection "Anonymous Hugs" as a gift for "third_user"
    Then "third_user" should be emailed
      And the email to "third_user" should not contain "first_user"
      And the email to "third_user" should contain "Anonymous"
    When subscription notifications are sent
    Then "second_user" should not be emailed
    When all emails have been delivered
      And I am logged in as "moderator"
      And I reveal authors for "Anonymous Hugs"
    Then the author of "Old Snippet" should be publicly visible
    When subscription notifications are sent
    Then "second_user" should be emailed
      And the email to "second_user" should contain "first_user"
      And "third_user" should not be emailed

  Scenario: The moderator can reveal a single author in an anonymous collection
    Given I have the anonymous collection "Anonymous Hugs"
      And "second_user" subscribes to author "first_user"
      And the user "third_user" exists and is activated
      And I am logged in as "first_user"
      And I post the work "First Snippet" to the collection "Anonymous Hugs" as a gift for "third_user"
      And I post the work "Second Snippet" to the collection "Anonymous Hugs" as a gift for "fourth_user"
    When subscription notifications are sent
    Then "second_user" should not be emailed
    When I am logged in as "moderator"
      And I view the approved collection items page for "Anonymous Hugs"
      # items listed in date order so checking the second will reveal the older work
      And I uncheck the 2nd checkbox with id matching "collection_items_\d+_anonymous"
      And I submit
    Then the author of "First Snippet" should be publicly visible
    When subscription notifications are sent
    Then "second_user" should be emailed
      And the email to "second_user" should contain "first_user"
      And the email to "second_user" should contain "First Snippet"
      And the email to "second_user" should not contain "Second Snippet"
    When I am logged out
    Then the author of "First Snippet" should be publicly visible
      And the author of "Second Snippet" should be hidden from me

  Scenario: Works should not be visible in series if unrevealed
    Given I have the hidden collection "Hidden Treasury"
      And I am logged in as "first_user"
      And I post the work "Before"
      And I add the work "Before" to series "New series"
      And I post the work "Hiding Work" to the collection "Hidden Treasury"
      And I add the work "Hiding Work" to series "New series"
      And I post the work "After"
      And I add the work "After" to series "New series"
    When "AO3-1250: series anonymity issues" is fixed
    ### even the author should not see the work listed within the series
    # Then the work "Hiding Work" should be part of the "New series" series in the database
    #   And the work "Hiding Work" should not be visible on the "New series" series page
    #   And the series "New series" should not be visible on the "Hiding Work" work page
    #   And the neighbors of "Hiding Work" in the "New series" series should link over it
    When I am logged out
    Then the work "Hiding Work" should be part of the "New series" series in the database
      And the work "Hiding Work" should not be visible on the "New series" series page
      And the series "New series" should not be visible on the "Hiding Work" work page
    When "AO3-1250: series anonymity issues" is fixed
    #  And I should not see "Mystery Work"
    #  And the neighbors of "Hiding Work" in the "New series" series should link over it
    When I reveal works for "Hidden Treasury"
      And I am logged out
    Then the work "Hiding Work" should be visible on the "New series" series page
      And the series "New series" should be visible on the "Hiding Work" work page
      And the neighbors of "Hiding Work" in the "New series" series should link to it
    
  Scenario: Works should not be visible in series if anonymous
    Given I have the anonymous collection "Anon Treasury"
      And I am logged in as "first_user"
      And I post the work "Before"
      And I add the work "Before" to series "New series"
      And I post the work "Anon Work" to the collection "Anon Treasury"
      And I add the work "Anon Work" to series "New series"
      And I post the work "After"
      And I add the work "After" to series "New series"
    Then the work "Anon Work" should be part of the "New series" series in the database
    When "AO3-1250: series anonymity fixes" is fixed
      # even the author should not see the work in the series
      # And the work "Anon Work" should not be visible on the "New series" series page
      # And the series "New series" should not be visible on the "Anon Work" work page
      # And the neighbors of "Anon Work" in the "New series" series should link over it
    When I am logged out
    Then the work "Anon Work" should be part of the "New series" series in the database
    When "AO3-1250: series anonymity fixes" is fixed
      # And the work "Anon Work" should not be visible on the "New series" series page
      # And the series "New series" should not be visible on the "Anon Work" work page
      # And the neighbors of "Anon Work" in the "New series" series should link over it
    When I reveal authors for "Anon Treasury"
      And I am logged out
    Then the work "Anon Work" should be visible on the "New series" series page
      And the series "New series" should be visible on the "Anon Work" work page
      And the neighbors of "Anon Work" in the "New series" series should link to it

  Scenario: Adding a co-author to (one chapter of) an anonymous work should still keep it anonymous
    Given I have the anonymous collection "Various Penguins"
      And I am logged in as "Jessica"
      And I post the chaptered work "Cone of Silence"
      And I add the work "Cone of Silence" to the collection "Various Penguins"
    When I edit the work "Cone of Silence"
      And I follow "2" within "div#main.works-edit.region"
      And I add the co-author "Amos"
      And I press "Post Without Preview"
    Then the author of "Cone of Silence" should be visible to me on the work page
    When I am logged out
    Then the author of "Cone of Silence" should be hidden from me
  
