@admin
Feature: Admin Actions to Post Known Issues
  As an an admin
  I want to be able to report known issues

  Scenario: Post known issues
    When I am logged in as an admin
      And I follow "Admin Posts"
      And I follow "Known Issues" within "#main"
      And I follow "make a new known issues post"
      And I fill in "known_issue_title" with "First known problem"
      And I fill in "content" with "This is a bit of a problem"
      # Suspect related to issue 2458
      And I press "Post"
    Then I should see "Known issue was successfully created"

  Scenario: Edit known issues
    # TODO
    Given I have posted known issues
    When I edit known issues
    Then I should see "Known issue was successfully updated"