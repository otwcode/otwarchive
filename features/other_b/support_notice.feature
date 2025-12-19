Feature: Notices on support page

  Scenario: Admin can set a support notice
    Given I am logged in as a "support" admin
    When I create an active "notice" support notice
      And I go to the support page
    Then I should see the "notice" support notice

  Scenario: Admin can set a caution support notice
    Given I am logged in as a "support" admin
    When I create an active "caution" support notice
      And I go to the support page
    Then I should see the "caution" support notice

  Scenario: Admin can set an error support notice
    Given I am logged in as a "support" admin
    When I create an active "error" support notice
      And I go to the support page
    Then I should see the "error" support notice

  Scenario: Admin can edit an active support notice
    Given I am logged in as a "support" admin
      And I create an active support notice
    When I edit the active support notice
      And I go to the support page
    Then I should see the edited active support notice

  Scenario: Admin can deactivate a support notice
    Given I am logged in as a "support" admin
      And I create an active support notice
    When I deactivate the support notice
      And I go to the support page
    Then I should not see a support notice

  Scenario: Admin can delete a support notice and it will no longer be shown to users
    Given I am logged in as a "support" admin
      And I create an active support notice
    When I am on the support page
    Then I should see the support notice
    When I deactivate the support notice
      And I am on the support page
    Then I should not see a support notice
    When I am on the support notices page
      And I follow "Delete"
      And I press "Yes, Delete Support Notice"
    Then I should see "Support notice successfully deleted."
    When I go to the support page
    Then I should not see a support notice

  Scenario: Activating a new support notice replaces the old one
    Given I am logged in as a "support" admin
      And I create an active support notice
      And I create a newer active support notice
    When I go to the support page
    Then I should see the new support notice

  Scenario: An active support notice cannot be deleted
    Given I am logged in as a "support" admin
      And I create an active support notice
    When I am on the support notices page
    Then I should not see "Delete"
