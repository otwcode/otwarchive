@admin @comments
Feature: Admin Actions to Draft News
  In order to post news items
  As an admin
  I want to be able to create drafts and preview my changes

  Scenario: Draft admin posts are only visible in the drafts index
    Given the admin post "New AO3 News"
      And the draft admin post "Newer AO3 News"
    When I am logged in as a "communications" admin
      And I am on the admin-posts page
    Then I should see "New AO3 News"
      And I should not see "Newer AO3 News"
    When I am on the admin-post drafts page
    Then I should see "Newer AO3 News"
      And I should not see "New AO3 News"
    When I am logged in as "ordinaryuser"
    And I am on the admin-posts page
    Then I should see "New AO3 News"
      And I should not see "Newer AO3 News"

  Scenario: Admins with only drafting permissions cannot post drafts or edit published news
    Given the admin post "New AO3 News"
    When I am logged in as a "policy_and_abuse" admin
      And I am on the admin-posts page
    Then I should see "New AO3 News"
      And I should see "Show"
      And I should not see "Edit"
      And I should not see "Delete"

  Scenario: Admins with drafting permissions can create, edit and delete drafts
    Given I am logged in as a "policy_and_abuse" admin
      And I am on the admin-post drafts page
      And time is frozen at Tue May 12 12:00:00 UTC 2026
    When I start to make an admin post
    Then I should see a button with text "Save As Draft"
      And I should not see a button with text "Post"
    When I press "Save As Draft"
    Then I should see "Admin Post was successfully created."
      And I should see "AO3 News Draft" within "#main"
    When time is frozen at Tue May 13 12:34:56 UTC 2026
      And I follow "Edit Draft"
      And I fill in "admin_post_title" with "New Post Title"
      And I press "Save As Draft"
    Then I should see "Admin Post was successfully updated."
      And I should see "New Post Title"
      And the page title should include "(Draft)"
    When I follow "Back to AO3 News Drafts"
    Then I should see "Created on Tue, 12 May 2026 12:00:00 +0000 and updated on Wed, 13 May 2026 12:34:56 +0000"

  Scenario: Admins with posting permissions can post drafts
    Given the draft admin post "My Draft Post"
      And I am logged in as a "communications" admin
      And I am on the admin-post drafts page
    Then I should see "My Draft Post"
    When I follow "Post Draft"
    Then I should see "Admin Post was successfully posted."
      And I should see "My Draft Post"
      And I should see "Published:"

  Scenario: Draft admin posts are sorted by creation time, newest first
    Given the draft admin post "First Post"
      And it is currently 1 second from now
      And the draft admin post "Second Post"
      And I am logged in as a "policy_and_abuse" admin
      And I am on the admin-post drafts page
    Then I "Second Post" should appear before "First Post"
    When I follow "First Post"
      And I follow "Next Draft"
    Then I should see "Second Post" within "#main"
    When I follow "Previous Draft"
    Then I should see "First Post" within "#main"

  Scenario: Previewed admin posts are not persisted
    Given I am logged in as a "communications" admin
      And the admin post "Perfection"
    When I start to make an admin post
      And I press "Preview"
    Then I should see "Default Admin Post"
    When I follow "Cancel"
    Then I should see "AO3 News" within "#main"
      And I should not see "Default Admin Post"
    When I follow "Perfection"
      And I follow "Edit Post"
      And I fill in "admin_post_title" with "Not so perfect"
      And I press "Preview"
    Then I should see "Not so perfect"
    When I follow "Cancel"
    Then I should see "Perfection"

  Scenario: Previewed admin posts can be persisted
    Given I am logged in as a "communications" admin
      And the admin post "Not so perfect"
      And I am on the admin-posts page
    When I follow "Not so perfect"
      And I follow "Edit Post"
      And I fill in "admin_post_title" with "Perfection"
      And I press "Preview"
    Then I should see "Perfection"
    When I press "Post"
    Then I should see "Admin Post was successfully updated."
      And I should see "Perfection"
      And I should not see "Not so perfect"

  Scenario: Draft admin posts can be filtered
    Given I am logged in as a "communications" admin
      And the draft admin post "Aardvark" with tag "apple"
      And the draft admin post "Peony" with tag "pear"
      And I am on the admin-post drafts page
    Then "apple" should be an option within "Tag"
      And "pear" should be an option within "Tag"
    When I select "apple" from "Tag"
      And I press "Go"
    Then I should see "Aardvark"
      And I should not see "Peony"

  Scenario: Translations of draft admin posts can be created, and are posted with the translated post
    Given basic languages
      And I am logged in as a "communications" admin
      And the draft admin post "Aardvark"
      And the draft admin post "Erdferkel" translating "Aardvark" to "Deutsch"
      And I am on the admin-post drafts page
    Then "English" should be an option within "Language"
      And "Deutsch" should be an option within "Language"
      And I should see "Aardvark"
      And I should not see "Erdferkel"
    When I select "Deutsch" from "Language"
      And I press "Go"
    Then I should see "Erdferkel"
      And I should not see "Aardvark"
      And I should not see "Post Draft"
    Then I should see "Erdferkel"
      And I should not see "Aardvark"
    When I follow "Erdferkel"
    Then I should see "Original: Aardvark"
    When I follow "Aardvark" within "#main"
    Then I should see "Translations: Deutsch"
    When I follow "Edit Draft"
      And I press "Post"
    Then I should see "Admin Post was successfully updated."
      And I should see "Translations: Deutsch"
    When I follow "Deutsch"
    Then I should see "AO3 News" within "#main"
      And I should not see "AO3 News Draft" within "#main"

  Scenario: Draft translations of posted admin posts can be posted
    Given basic languages
      And I am logged in as a "communications" admin
      And the admin post "Aardvark"
      And the draft admin post "Erdferkel" translating "Aardvark" to "Deutsch"
      And I am on the admin-posts page
    When I follow "Aardvark"
    Then I should not see "Translations:"
    When I am on the admin-post drafts page
    When I select "Deutsch" from "Language"
      And I press "Go"
    Then I should see "Erdferkel"
    When I follow "Post Draft"
    Then I should see "Admin Post was successfully posted."
      And I should see "Erdferkel"
      And I should see "Original: Aardvark"
    When I follow "Aardvark" within "#main"
    Then I should see "Translations: Deutsch"
