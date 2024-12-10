Feature: Suspensions
  
  Scenario: Users suspended on 2024-01-11 before the unban threshold can see they will be unbanned on 2024-02-10
    Given the user "mrparis" exists and is activated
      And it is currently 2024-01-11 01:00 AM
      And the user "mrparis" is suspended
      And I am logged in as "mrparis"
      And I go to the new work page
    Then I should see "suspended until Sat 10 Feb 2024"

  Scenario: Users suspended on 2024-01-11 after the unban threshold can see they will be unbanned on 2024-02-11
      Given the user "mrparis" exists and is activated
        And it is currently 2024-01-11 08:00 PM
        And the user "mrparis" is suspended
        And I am logged in as "mrparis"
        And I go to the new work page
      Then I should see "suspended until Sun 11 Feb 2024"
