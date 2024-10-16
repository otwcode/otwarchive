@admin
Feature: Admin Actions to Post Known Issues
  As an an admin
  I want to be able to report known issues

  Scenario Outline: Authorized admin posts, edits, and deletes known issues
    Given I am logged in as a "<role>" admin
    When I follow "Admin Posts"
      And I follow "Known Issues" within "#header"
      And I follow "make a new known issues post"
      And I fill in "known_issue_title" with "First known problem"
      And I fill in "content" with "This is a bit of a problem"
      # Suspect related to issue 2458
      And I press "Post"
    Then I should see "Known issue was successfully created"
      And I should see "First known problem"
    When I follow "Admin Posts"
      And I follow "Known Issues" within "#header"
      And I follow "Show"
    Then I should see "First known problem"
    When I edit known issues
    Then I should see "Known issue was successfully updated"
      And I should not see "First known problem"
      And I should see "This is a bit of a problem, and this is too"
    When I delete known issues
    Then I should not see "First known problem"

    Examples:
    | role       |
    | support    |
    | superadmin |

  Scenario Outline: Links to edit and create known issues are not shown to unauthorized admins
    Given I have posted known issues
      And I am logged in as a "<role>" admin
    When I follow "Admin Posts"
    Then I should not see "Known Issues" within "#header"
    When I go to the known issues page
    Then I should not see "Edit" within ".actions"

    Examples:
    | role                       |
    | board                      |
    | board_assistants_team      |
    | communications             |
    | development_and_membership |
    | docs                       |
    | elections                  |
    | legal                      |
    | translation                |
    | tag_wrangling              |
    | policy_and_abuse           |
    | open_doors                 |
