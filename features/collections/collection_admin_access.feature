@collection

Feature: Admin access to collection pages
  Admins with support, policy_and_abuse, or superadmin roles should be
  able to view all collection and challenge pages that owners can access,
  but should not be able to make changes.

  # ============================================================
  # General Collection Pages
  # ============================================================

  Scenario: Support admin can access the Manage Items page with no items
    Given I have a collection "Owned Collection"
      And I am logged in as a "support" admin
    When I view the awaiting collection approval collection items page for "Owned Collection"
    Then I should see "Items in"
      And I should not see "You don't have permission"

  Scenario: Support admin can access the Manage Items page with items
    Given I am logged in as "author"
      And I set my preferences to allow collection invitations
      And I post the work "Admin Viewable Work"
      And I have a collection "Items Collection"
      And I am logged in as "moderator"
      And I invite the work "Admin Viewable Work" to the collection "Items Collection"
      And I am logged in as "author"
      And "author" accepts the invitation for their work in the collection "Items Collection"
      And I press "Submit"
    When I am logged in as a "support" admin
      And I view the approved collection items page for "Items Collection"
    Then I should see "Admin Viewable Work"

  Scenario: Support admin can access all Manage Items status pages
    Given I am logged in as "author"
      And I set my preferences to allow collection invitations
      And I post the work "Test Work"
      And I have a moderated collection "Moderated Collection"
      And I am logged in as "moderator"
      And I invite the work "Test Work" to the collection "Moderated Collection"
    When I am logged in as a "support" admin
      And I view the awaiting collection approval collection items page for "Moderated Collection"
    Then I should not see "You don't have permission"
    When I view the awaiting user approval collection items page for "Moderated Collection"
    Then I should not see "You don't have permission"
    When I view the rejected by collection collection items page for "Moderated Collection"
    Then I should not see "You don't have permission"
    When I view the rejected by user collection items page for "Moderated Collection"
    Then I should not see "You don't have permission"

  Scenario: Support admin can access Collection Settings page
    Given I have a collection "Settings Collection"
      And I am logged in as a "support" admin
    When I go to "Settings Collection" collection edit page
    Then I should see "Edit Collection"

  Scenario: Support admin cannot update collection settings
    Given I have a collection "No Edit Collection"
      And I am logged in as a "support" admin
    When I go to "No Edit Collection" collection edit page
      And I press "Update"
    Then I should see "Please log out of your admin account first!"

  Scenario: Support admin can access Membership page
    Given I have a collection "Members Collection"
      And I am logged in as a "support" admin
    When I go to the "Members Collection" participants page
    Then I should see "Members of"

  Scenario: Support admin cannot add members
    Given I have a collection "No Add Member Collection"
      And I am logged in as a "support" admin
    When I go to the "No Add Member Collection" participants page
      And I fill in "participants_to_invite" with "someone"
      And I press "Submit"
    Then I should see "Please log out of your admin account first!"

  Scenario: Policy and abuse admin can access collection pages
    Given I have a collection "PAB Collection"
      And I am logged in as a "policy_and_abuse" admin
    When I go to "PAB Collection" collection edit page
    Then I should see "Edit Collection"
    When I go to the "PAB Collection" participants page
    Then I should see "Members of"

  Scenario: Superadmin can access collection pages
    Given I have a collection "Super Collection"
      And I am logged in as a super admin
    When I go to "Super Collection" collection edit page
    Then I should see "Edit Collection"
    When I go to the "Super Collection" participants page
    Then I should see "Members of"

  Scenario: Unauthorized admin roles cannot access collection management pages
    Given I have a collection "Restricted Collection"
      And I am logged in as a "tag_wrangling" admin
    When I go to "Restricted Collection" collection edit page
    Then I should see "Sorry, only an authorized admin can access the page you were trying to reach."

  # ============================================================
  # Gift Exchange Pages
  # ============================================================

  Scenario: Support admin can access gift exchange sign-ups
    Given I have created the gift exchange "GE Admin Test"
      And I open signups for "GE Admin Test"
      And I am logged in as "signer1"
      And I sign up for "GE Admin Test" with combination A
    When I am logged in as a "support" admin
      And I go to the "GE Admin Test" signups page
    Then I should see "Sign-ups"
      And I should see "signer1"

  Scenario: Support admin can access an individual sign-up
    Given I have created the gift exchange "GE Signup View"
      And I open signups for "GE Signup View"
      And I am logged in as "signer1"
      And I sign up for "GE Signup View" with combination A
    When I am logged in as a "support" admin
      And I go to the "GE Signup View" signups page
      And I follow "signer1"
    Then I should see "Sign-up for"
      And I should see "signer1"

  Scenario: Support admin can access the Requests Summary
    Given I have created the gift exchange "GE Requests"
      And I open signups for "GE Requests"
      And I am logged in as "signer1"
      And I sign up for "GE Requests" with combination A
    When I am logged in as a "support" admin
      And I go to the "GE Requests" requests page
    Then I should not see "You are not allowed to view the requests summary!"

  Scenario: Support admin can access the Matching page
    Given I have created the gift exchange "GE Matching"
      And I open signups for "GE Matching"
    When I am logged in as a "support" admin
      And I go to "GE Matching" gift exchange matching page
    Then I should not see "Sorry, you don't have permission"

  Scenario: Support admin cannot generate potential matches
    Given I have created the gift exchange "GE No Match"
      And I open signups for "GE No Match"
      And I am logged in as "signer1"
      And I sign up for "GE No Match" with combination A
      And I am logged in as "signer2"
      And I sign up for "GE No Match" with combination B
      And I close signups for "GE No Match"
    When I am logged in as a "support" admin
      And I go to "GE No Match" gift exchange matching page
      And I press "Generate Potential Matches"
    Then I should see "Please log out of your admin account first!"

  Scenario: Support admin can access Assignments page
    Given everyone has their assignments for "GE Assignments"
    When I am logged in as a "support" admin
      And I go to the "GE Assignments" assignments page
    Then I should see "Assignments"

  Scenario: Support admin can access gift exchange Challenge Settings
    Given I have created the gift exchange "GE Settings"
    When I am logged in as a "support" admin
      And I go to "GE Settings" gift exchange edit page
    Then I should see "Setting Up the"

  Scenario: Support admin cannot update gift exchange settings
    Given I have created the gift exchange "GE No Edit"
    When I am logged in as a "support" admin
      And I go to "GE No Edit" gift exchange edit page
      And I press "Update"
    Then I should see "Please log out of your admin account first!"

  Scenario: Support admin cannot delete a gift exchange challenge
    Given I have created the gift exchange "GE No Delete"
    When I am logged in as a "support" admin
      And I go to "GE No Delete" gift exchange edit page
      And I follow "Delete Challenge"
    Then I should see "Please log out of your admin account first!"

  Scenario: Support admin cannot default assignments
    Given everyone has their assignments for "GE No Default"
    When I am logged in as a "support" admin
      And I go to the "GE No Default" assignments page
      And I press "Default All Incomplete"
    Then I should see "Please log out of your admin account first!"

  Scenario: Support admin cannot purge assignments
    Given everyone has their assignments for "GE No Purge"
    When I am logged in as a "support" admin
      And I go to the "GE No Purge" assignments page
      And I follow "Purge Assignments"
    Then I should see "Please log out of your admin account first!"

  Scenario: Unauthorized admin cannot access gift exchange sign-ups
    Given I have created the gift exchange "GE Restricted"
      And I open signups for "GE Restricted"
    When I am logged in as a "tag_wrangling" admin
      And I go to the "GE Restricted" signups page
    Then I should see "Sorry, only an authorized admin can access the page you were trying to reach."

  # ============================================================
  # Prompt Meme Pages
  # ============================================================

  Scenario: Support admin can access prompt meme Unposted Claims
    Given I have Battle 12 prompt meme fully set up
      And I open signups for "Battle 12"
      And I am logged in as "signer1"
      And I sign up for Battle 12 with combination A
    When I am logged in as a "support" admin
      And I go to the "Battle 12" claims page
    Then I should not see "Sorry, you don't have permission"

  Scenario: Support admin can access prompt meme Challenge Settings
    Given I have Battle 12 prompt meme fully set up
    When I am logged in as a "support" admin
      And I go to "Battle 12" prompt meme edit page
    Then I should see "Setting Up the"

  Scenario: Support admin cannot update prompt meme settings
    Given I have Battle 12 prompt meme fully set up
    When I am logged in as a "support" admin
      And I go to "Battle 12" prompt meme edit page
      And I press "Update"
    Then I should see "Please log out of your admin account first!"

  Scenario: Unauthorized admin cannot access prompt meme claims
    Given I have Battle 12 prompt meme fully set up
    When I am logged in as a "tag_wrangling" admin
      And I go to the "Battle 12" claims page
    Then I should see "Sorry, only an authorized admin can access the page you were trying to reach."

  Scenario: Unauthorized admin cannot access prompt meme Challenge Settings
    Given I have Battle 12 prompt meme fully set up
    When I am logged in as a "tag_wrangling" admin
      And I go to "Battle 12" prompt meme edit page
    Then I should see "Sorry, only an authorized admin can access the page you were trying to reach."
