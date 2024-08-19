@admin
Feature: Admin Actions to manage users
  In order to manage user accounts
  As an an admin
  I want to be able to edit individual users

  Scenario: Admin can update a user's email address and roles
    Given the following activated user exists
      | login | password    |
      | dizmo | wrangulator |
    And I have loaded the "roles" fixture
    When I am logged in as a super admin
    And I go to the manage users page
    And I fill in "Name" with "dizmo"
    And I press "Find"
    Then I should see "dizmo" within "#admin_users_table"

    # change user email
    When I fill in "user_email" with "not even an email"
      And I press "Update"
    Then I should see "The user dizmo could not be updated: Email is invalid"

    When I fill in "user_email" with "dizmo@fake.com"
      And I press "Update"
    Then the "user_email" field should contain "dizmo@fake.com"
      And I should see "User was successfully updated."

    # Adding and removing roles
    When I check "user_roles_1"
      And I press "Update"
    # Then show me the html
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should be checked
    When I follow "Details"
    Then I should see "Role: Tag Wrangler" within ".meta"
      And I should see "Role Added: tag_wrangler" within "#user_history"
      And I should see "Change made by testadmin-superadmin"
    When I follow "Manage Roles"
      And I uncheck "user_roles_1"
      And I press "Update"
    Then I should see "User was successfully updated"
      And the "user_roles_1" checkbox should not be checked
    When I follow "Details"
    Then I should see "Roles: No roles" within ".meta"
    And I should see "Role Removed: tag_wrangler" within "#user_history"

  Scenario: Troubleshooting a user displays a message
    Given the user "mrparis" exists and is activated
      And I am logged in as a "support" admin
    When I go to the user administration page for "mrparis"
      And I follow "Troubleshoot"
    Then I should see "User account troubleshooting complete."

  Scenario: A admin can activate a user account
    Given the user "mrparis" exists and is not activated
      And I am logged in as a "support" admin
    When I go to the user administration page for "mrparis"
      And I press "Activate"
    Then I should see "User Account Activated"
      And the user "mrparis" should be activated

  Scenario: An admin can view a user's last login date
    Given the user "new_user" exists and is activated
      And I am logged in as a "support" admin
    When I go to the user administration page for "new_user"
    Then I should see "Current Login No login recorded"
      And I should see "Previous Login No previous login recorded"
    When time is frozen at 1/1/2019
      And I am logged in as "new_user"
      And I am logged out
      And I jump in our Delorean and return to the present
      And I am logged in as a "support" admin
      And I go to the user administration page for "new_user"
    Then I should not see "No login recorded"
      And I should see "2019-01-01 12:00:00 UTC Current Login IP Address: 127.0.0.1"
      And I should see "2019-01-01 12:00:00 UTC Previous Login IP Address: 127.0.0.1"

  Scenario: An admin can view a user's email address and invitation
    Given the user "user" with the email "user@example.com" exists
      And the user "user2" was created using an invitation
    When I am logged in as a "superadmin" admin
      And I go to the user administration page for "user"
    Then I should see "Email: user@example.com"
      And I should see "Invitation: Created without invitation"
    When I go to the user administration page for "user2"
    Then I should see the invitation id for the user "user2"

  Scenario: An admin can access a user's creations from their administration page
    Given there is 1 user creation per page
      And the user "lurker" exists and is activated
      And I am logged in as "troll"
      And I post the work "Creepy Gift"
      And I post the work "NFW"
      And I post the comment "Neener" on the work "Creepy Gift"
    When I am logged in as a "support" admin
      And I go to the user administration page for "lurker"
    Then the page should have a dashboard sidebar
      And I should not see "Creations"
    When I am logged in as a "policy_and_abuse" admin
      And I go to the user administration page for "lurker"
      And I follow "Creations"
    Then I should see "Works and Comments by lurker"
      And I should see "This user has no works or comments."
      And the page should have a dashboard sidebar
    When I go to the user administration page for "troll"
      And I follow "Creations"
    Then I should see "Works and Comments by troll"
      And I should see "1 - 1 of 2 Works" within "#works-summary"
      And I should see "Creepy Gift" within "#works-summary"
      And I should see "1 Comment" within "#comments-summary"
      And I should see "Comment on the work Creepy Gift" within "#comments-summary"
      And I should see "<p>Neener</p>" within "#comments-summary"
