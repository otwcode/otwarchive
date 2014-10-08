@admin
Feature: Admin Actions for notifications
	In order to send notifications
	As an an admin
	I want to be able to use the Admin Notifications screen

  Scenario: Send out an admin notice to all users
  Given I have no users
    And the following admin exists
      | login       | password |
      | Zooey       | secret   |
    And the following activated user exists
      | login       | password             | email   |
      | enigel      | emailnotifications   | e@e.org |
      | otherfan    | hatesnotifications   | o@e.org |
    And all emails have been delivered

  # otherfan turns off notifications

  When I am logged in as "otherfan" with password "hatesnotifications"
    And I go to my preferences page
    And I check "Turn off admin emails"
    And I press "Update"
  Then I should see "Your preferences were successfully updated"

  # admin sends out notice to all users

  When I am logged in as an admin
    And I go to the admin-notices page
    And I fill in "Subject" with "Hey, we did stuff"
    And I fill in "Message" with "And it was awesome"
    And I check "Notify All Users"
    And I press "Send Notification"
  Then 1 email should be delivered to webmaster@example.org
    And the email should not contain "otherfan"
    And the email should contain "enigel"
  When the system processes jobs
  # confirmation email to admin, and to one user
      Then 1 email should be delivered to e@e.org
    # Hack for HTML emails. 'Enigel' is a link in the new mailers, tests not catching that
    And the email should contain "Dear"
    And the email should contain "enigel"
    And the email should have "\[AO3\] Admin Message - Hey, we did stuff" in the subject
    And the email should contain "And it was awesome"
  Then 1 email should be delivered to webmaster@example.org
    And the email should have "\[AO3\] Admin Archive Notification Sent - Hey, we did stuff" in the subject
