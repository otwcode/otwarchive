Feature: Notices on support page

Scenario: Support notice is blank until admin sets it
  Given there are no support notices
  Then I should not see a support notice

Scenario: Admin can set a support notice
  Given there are no support notices
  When an admin creates an active "notice" support notice
  Then I should see the "notice" support notice

Scenario: Admin can set a caution support notice
  Given there are no support notices
  When an admin creates an active "caution" support notice
  Then I should see the "caution" support notice

Scenario: Admin can set an error support notice
  Given there are no support notices
  When an admin creates an active "error" support notice
  Then I should see the "error" support notice

Scenario: Admin can edit an active support notice
  Given there are no support notices
    And an admin creates an active support notice
  When an admin edits the active support notice
  Then I should see the edited active support notice

Scenario: Admin can deactivate a support notice
  Given there are no support notices
    And an admin creates an active support notice
  When an admin deactivates the support notice
  Then I should not see a support notice

Scenario: Admin can delete a support notice and it will no longer be shown to users
  Given there are no support notices
    And an admin creates a support notice
  When I am logged in as a "support" admin
    And I am on the support notices page
    And I follow "Delete"
    And I press "Yes, Delete Support Notice"
  Then I should see "Support Notice successfully deleted."
  When I am logged in as a random user
  Then I should not see a support notice

Scenario: Activating a new support notice replaces the old one
  Given there are no support notices
    And an admin creates an active support notice
    And an admin creates a newer active support notice
  When I am logged in as a random user
    Then I should see the new support notice

  Scenario: An active support notice cannot be deleted
    Given there are no support notices
      And an admin creates an active support notice
    When I am logged in as a "support" admin
      And I am on the support notices page
    Then I should not see "Delete"
