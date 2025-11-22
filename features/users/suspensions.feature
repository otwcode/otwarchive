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

  Scenario: Suspended user sees correct date on login before unban threshold
    Given the user "mrparis" exists and is activated
      And it is currently 2024-01-11 01:00 AM
      And the user "mrparis" is suspended
      And I log out
    When I am on the home page
      And I fill in "Username or email:" with "mrparis"
      And I fill in "Password:" with "password"
      And I press "Log In"
    Then I should see "suspended until Sat 10 Feb 2024"

  Scenario: Suspended user sees correct date on login after unban threshold
    Given the user "mrparis" exists and is activated
      And it is currently 2024-01-11 08:00 PM
      And the user "mrparis" is suspended
      And I log out
    When I am on the home page
      And I fill in "Username or email:" with "mrparis"
      And I fill in "Password:" with "password"
      And I press "Log In"
    Then I should see "suspended until Sun 11 Feb 2024"
