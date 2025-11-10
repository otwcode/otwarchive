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
