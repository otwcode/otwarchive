Feature: Display autocomplete for tags
  In order to facilitate posting
  I should be getting autocompletes for my tags

  Scenario: Autocomplete tests should be added when javascript testing is enabled
  When "AO3-4369: Javascript enabled for automated tests" is fixed
  # uncomment all the below tests which currently DO NOT WORK
  
# Scenario: Only matching canonical tags should appear in autocomplete, and searching for the same data twice should produce same results
#   Given I am logged in
#     And a set of tags for testing autocomplete
#      And I go to the new work page
#   Then the tag autocomplete fields should list only matching canonical tags
#
# Scenario: For fandom-specific autocomplete, if a fandom is entered then only characters/relationships within the fandom should appear in autocomplete
#   Given I am logged in
#     And a set of tags for testing autocomplete
#      And I go to the new work page
#    Then the fandom-specific tag autocomplete fields should list only fandom-specific canonical tags
#
# Scenario: Bookmark archive work form autocomplete should work
#   Given I am logged in
#     And a set of tags for testing autocomplete
#   When I start a new bookmark
#     And I enter text in the "Your Tags" autocomplete field
#   Then I should only see matching canonical tags in the autocomplete
#
# Scenario: Bookmark external work form autocomplete should work
#   Given I am logged in
#     And a set of tags for testing autocomplete
#     And an external work
#   When I go to the new external work page
#   Then the tag autocomplete fields should list only matching canonical tags
#     And the fandom-specific tag autocomplete fields should list only fandom-specific canonical tags
#     And the external url autocomplete field should list the urls of existing external works
#
# Scenario: Pseud and collection autocompletes should work
#   Given I am logged in
#     And a set of collections for testing autocomplete
#     And a set of users for testing autocomplete
#      And I go to the new work page
#   Then the coauthor autocomplete field should list matching users
#     And the gift recipient autocomplete field should list matching users
#     And the collection item autocomplete field should list matching collections
#
# Scenario: Collection autocomplete shows Collection Title and Name
#   Given I have the collection "Issue" with name "jb_fletcher"
#     And I have the collection "Issue" with name "robert_stack"
#     And I am logged in as "Scott" with password "password"
#     And I post the work "All The Nice Things"
#     And I view the work "All The Nice Things"
#     And I follow "Add To Collections"
#     And I fill in "collection_names" with "Issue"
#   Then I should see "jb_fletcher" in the autocomplete
#     And I should see "robert_stack" in the autocomplete

Scenario: Pseuds should be added and removed from autocomplete as they are changed
  Given I have flushed Redis
    And I am logged in as "new_user"
  Then the pseud autocomplete should contain "new_user"
  When I add the pseud "extra"
  Then the pseud autocomplete should contain "extra (new_user)"
  When I change the pseud "extra" to "funny"
    And I go to my pseuds page
  Then I should not see "extra"
    And I should see "funny"
    And the pseud autocomplete should not contain "extra (new_user)"
    And the pseud autocomplete should contain "funny (new_user)"
  When I delete the pseud "funny"
  Then the pseud autocomplete should not contain "funny (new_user)"
    And the pseud autocomplete should contain "new_user"
    
Scenario: Pseuds should be added and removed from autocomplete as usernames change
  Given I have flushed Redis
    And I am logged in as "new_user"
    And I add the pseud "funny"
  When I change my username to "different_user"
  Then the pseud autocomplete should not contain "funny (new_user)"
    And the pseud autocomplete should not contain "new_user"
    And the pseud autocomplete should contain "different_user"
    And the pseud autocomplete should contain "funny (different_user)"
  When I change my username to "funny"
  Then the pseud autocomplete should not contain "funny (different_user)"
    And the pseud autocomplete should contain "funny"
    And the pseud autocomplete should contain "different_user (funny)"
  When I try to delete my account as funny
  Then a user account should not exist for "funny"
    And the pseud autocomplete should not contain "funny"
    And the pseud autocomplete should not contain "different_user (funny)"
    
    
  
