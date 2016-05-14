@collection @works

Feature: Collection
  In order to have a collection full of curated works
  As a collection maintainer
  I want to add and invite works to my collection

Scenario: Invite a work to a collection where a user auto-approves inclusion
Given I am logged in as "Scott" with password "password"
  And I go to Scott's preferences page
  And I check "preference_automatically_approve_collections"
  And I press "Update"
  And I post the work "A Death in Hong Kong" with fandom "Murder She Wrote"
When I have the collection "scotts collection" with name "scotts_collection"
  And I am logged in as "moderator" with password "password"
  And I view the work "A Death in Hong Kong"
  And I follow "Add To Collections"
  And I fill in "collection_names" with "scotts_collection"
  And I press "Add"
  And I should see "Added to collection(s): scotts collection."
  And 1 email should be delivered to "Scott"
  And the email should contain "you have previously elected to allow"
When I am logged in as "moderator" with password "password"
  And I go to "scotts collection" collection's page
  And I follow "Manage Items"
  And I follow "Approved"
Then I should see "A Death in Hong Kong"


Scenario: Invite a work to a collection where a users approves inclusion
Given I am logged in as "Scott" with password "password"
  And I go to Scott's preferences page
  And I uncheck "preference_automatically_approve_collections"
  And I press "Update"
  And I post the work "Murder in Milan" with fandom "Murder She Wrote"
When I have the collection "scotts collection" with name "scotts_collection"
  And I am logged in as "moderator" with password "password"
  And I view the work "Murder in Milan"
  And I follow "Add To Collections"
  And I fill in "collection_names" with "scotts_collection"
  And I press "Add"
  And I should see "This work has been Invited to your collection (scotts collection)."
  And 1 email should be delivered to "Scott"
  And the email should contain "If in future you would prefer to automatically approve requests to add your"
When I go to "scotts collection" collection's page
  And I should see "Works (0)"
  And I follow "Manage Items"
  And I follow "Invited"
  And I should see "Murder in Milan"
  And I should see "Works listed here have been invited to this collection. Once a work's creator has approved inclusion in this collection, the work will be moved to 'Approved'."
When I am logged in as "Scott" with password "password"
  And I accept the invitation for my work in the collection "scotts collection"
  And I press "Submit"
  And I should not see "Murder in Milan"
  And I follow "Approved"
  And I should see "Murder in Milan"
When I am logged in as "moderator" with password "password"
  And I am on "scotts collection" collection's page
  And I follow "Manage Items"
  And I should not see "Murder in Milan"
  And I follow "Approved"
Then I should see "Murder in Milan"


