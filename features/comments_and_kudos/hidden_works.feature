Feature: Comments on Hidden Works
  Scenario: When a work is hidden, admins and the creator can see (but not edit or add) comments, while everyone else is redirected.
    Given I am logged in as "creator"
      And I post the work "To Be Hidden"
      And I post the comment "Can I change this?" on the work "To Be Hidden"
      And I am logged in as "commenter"
      And I post the comment "Do you see?" on the work "To Be Hidden"
      And I am logged in as an admin
      And I view the work "To Be Hidden"
      And I follow "Hide Work"

    When I go to the work comments page for "To Be Hidden"
    Then I should see "Do you see?"
      But I should not see "Reply"
      And I should not see "Post Comment"
      And I should see "Sorry, you can't add or edit comments on a hidden work."

    When I am logged in as "creator"
      And I go to the work comments page for "To Be Hidden"
    Then I should see "Do you see?"
      And I should see "Can I change this?"
      But I should not see "Reply"
      And I should not see "Post Comment"
      And I should not see "Edit"
      And I should see "Sorry, you can't add or edit comments on a hidden work."

    When I am logged in as "commenter"
      And I go to the work comments page for "To Be Hidden"
    Then I should not see "Do you see?"
      And I should not see "Sorry, you can't add or edit comments on a hidden work."
      But I should see "Sorry, you don't have permission to access the page you were trying to reach."

    When I am logged out
      And I go to the work comments page for "To Be Hidden"
    Then I should not see "Do you see?"
      And I should not see "Sorry, you can't add or edit comments on a hidden work."
      But I should see "Sorry, you don't have permission to access the page you were trying to reach."
