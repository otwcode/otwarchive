@errors
Feature: Error messages

  Scenario: Error messages should be able to display '^'
    Given I am logged in as a random user
      And I post the work "Work 1"
      And I view the work "Work 1"
      And I follow "Edit Tags"
    When I fill in "Fandoms" with "^"
      And I press "Update"
    Then I should see "Sorry! We couldn't save this work because: Tag name '^' cannot include the following restricted characters: , ^ * < > { } = ` ， 、 \ %"
    
  Scenario: Error messages should display the entire user input when containing '^'
    Given I am logged in as "skinner"
      And I am on the skins page
      And I follow "My Site Skins"
      And I follow "Create Site Skin"
      And I fill in "Title" with "Broken CSS Test"
      And I fill in "CSS" with ".test { v^lue: blue; }"
    When I submit
    Then I should see "v^lue -- please notify Support if you think this is an error."
