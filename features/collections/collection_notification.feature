@collections @works

Feature: Collectible items email
  As a moderator
  I want to get notifications when items are added to my collection
  
  Scenario: Work added to collection sends notification email
    Given I am logged in as "first_user"
      And all emails have been delivered
    When I go to the collections page
    When I follow "New Collection"
     And I fill in "Display Title" with "Antarctic Penguins"
     And I fill in "Collection Name" with "AntarcticPenguins"
     And I fill in "Collection Email" with "test@archiveofourown.org"
     And I check the 1st checkbox with id matching "collection_collection_preference_attributes_email_notify"
     And I submit
    Then I should see "Collection was successfully created"
    When I go to the collections page
    When I follow "New Collection"
     And I fill in "Display Title" with "Polar Bears"
     And I fill in "Collection Name" with "PolarBears"
     And I fill in "Collection Email" with "test2@archiveofourown.org"
     And I check the 1st checkbox with id matching "collection_collection_preference_attributes_email_notify"
     And I submit
    Then I should see "Collection was successfully created"
    When I post the work "collect-y work"
     And I go to first_user's user page
    When I edit the work "collect-y work"
     And I fill in "work_collection_names" with "AntarcticPenguins"
     And I press "Preview"
    Then I should see "Preview"
     And I press "Update"
    Then I should see "Work was successfully updated."
     And I should see "collect-y work"
     And I should see "Antarctic Penguins"
     And 1 email should be delivered to test@archiveofourown.org
    When I edit the work "collect-y work"
    And I fill in "work_collection_names" with "AntarcticPenguins, PolarBears"
    And I press "Preview"
   Then I should see "Preview"
    And I press "Update"
   Then I should see "Work was successfully updated."
    And I should see "collect-y work"
    And I should see "Polar Bears"
    And I should see "Antarctic Penguins"
    And 1 email should be delivered to test2@archiveofourown.org