@collection

  Feature: Collection

  Scenario: A collection owner can't remove the owner from a collection
  Given I have the collection "Such a nice collection"
    And I am logged in as the owner of "Such a nice collection"
  When I am on the "Such a nice collection" participants page
    And I press "Remove"
  Then I should see "You can't remove the only owner!"

  Scenario: A collection owner can invite, update, and remove a collection member
  Given a user exists with login: "sam"
    And I have the collection "Such a nice collection"
    And I am logged in as the owner of "Such a nice collection"
  When I am on the "Such a nice collection" participants page
    And I fill in "participants_to_invite" with "sam"
    And I press "Submit"
  Then I should see "New members invited: sam"
    And "sam" should have the "Member" role in the collection "Such a nice collection"
  When I select "Owner" from "sam_role"
     And I submit with the 4th button
  Then I should see "Updated sam."
    And "sam" should have the "Owner" role in the collection "Such a nice collection"
  When I click the 2nd button
  Then I should see "Removed sam from collection."

  Scenario: Owner can invite own pseud to the collection
  Given I have the collection "Such a nice collection"
    And I have the collection "Woah another collection"
    And I am logged in as the owner of "Such a nice collection"
    And "moderator" creates the pseud "moderator_pseud"
  When the dashboard counts have expired
    And I follow "My Dashboard"
  Then I should see "Collections (2)"
  When I am on the "Such a nice collection" participants page
    And I fill in "participants_to_invite" with "moderator_pseud (moderator)"
    And I press "Submit"
  Then I should see "New members invited: moderator_pseud (moderator)"
  When I give "moderator_pseud (moderator)" the "Owner" role in the collection "Such a nice collection"
  Then I should see "Updated moderator_pseud."
    And "moderator_pseud (moderator)" should have the "Owner" role in the collection "Such a nice collection"
  When the dashboard counts have expired
    And I follow "My Dashboard"
  Then I should see "Collections (2)"

  Scenario: Owner can't invite a nonexistent user to the collection
  Given I have the collection "Such a nice collection"
    And I am logged in as the owner of "Such a nice collection"
  When I am on the "Such a nice collection" participants page
    And I fill in "participants_to_invite" with "sam"
    And I press "Submit"
  Then I should see "We couldn't find anyone new by that name to add."

  Scenario: Collection owner can't invite a banned user to a collection
  Given a user exists with login: "sam"
    And user "sam" is banned
    And I have the collection "Such a nice collection"
    And I am logged in as the owner of "Such a nice collection"
  When I am on the "Such a nice collection" participants page
    And I fill in "participants_to_invite" with "sam"
    And I press "Submit"
  Then I should see "sam cannot participate in challenges."

  Scenario: A user can ask to join a closed collection
  Given I have a moderated closed collection "Such a nice collection"
    And I am logged in as "sam"
  When I go to "Such a nice collection" collection's page
    And I press "Join"
  Then I should see "You have applied to join Such a nice collection"

  Scenario: A collection owner can preapprove a user to join a closed collection
  Given I have a moderated closed collection "Such a nice collection"
    And I am in sam's browser
    And I am logged in as "sam"
  When I go to "Such a nice collection" collection's page
  When I am in the moderator's browser
    And I am logged in as the owner of "Such a nice collection"
    And I am on the "Such a nice collection" participants page
    And I fill in "participants_to_invite" with "sam"
    And I press "Submit"
  Then I should see "New members invited: sam"
  When I select "Invited" from "sam_role"
    And I submit with the 4th button
  Then I should see "Updated sam."
  When I am in sam's browser
    And I press "Join"
  Then I should see "You are now a member of Such a nice collection"
  When I am in the default browser

  Scenario: A subcollection profile and blurb do not show duplicates when a moderator is also an owner of the parent collection
    Given a user exists with login: "sam"
      And I have the collection "Collection"
      And I am logged in as the owner of "Collection"
      And I have added the co-owner "sam" to collection "Collection"
      And I add the subcollection "Subcollection" to the parent collection named "Collection"
      And I have added the co-moderator "sam" to collection "Subcollection"
    When I go to "Subcollection" collection's page
      And I follow "Profile"
    Then I should see "sam" exactly 1 time 
    When I go to "Collection" collection's page
      And I follow "Subcollections"
    Then I should see "sam" exactly 1 time

Scenario: Collection member should see correct button text
  Given I have the moderated collection "ModeratedCollection"
    And I have the moderated collection "ModeratedCollectionTheSequel"
    And I am logged in as "sam"
    And I have joined the collection "ModeratedCollection" as "sam"
  When I am on the collections page
  Then I should see "Leave" exactly 1 time
    And I should see "Join" exactly 1 time
