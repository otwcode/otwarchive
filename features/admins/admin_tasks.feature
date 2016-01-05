@admin
Feature: Admin tasks
  Scenario: admin goes to the Support page

  Given I am logged in as an admin
  When I go to the support page
  Then I should see "Support and Feedback"
    And I should see "testadmin@example.org" in the "feedback_email" input

  Scenario: Admin views stats page

  Given I am logged in as an admin
  When I go to the admin-stats page
  Then I should see "Fun With Graphs"
  When I follow "Works Stats"
  Then I should see "Works Created per Week"
  When I follow "Users Stats"
  Then I should see "Users Created per Week"
  When I follow "Tags Stats"
  Then I should see "Tag stats coming soon"
  When I follow "Invitations Stats"
  Then I should see "Invitations by Status"
