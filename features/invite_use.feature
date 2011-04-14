Feature: invitations
In order to join the archive
As an unregistered user
I want to use an invitation to create an account

  Scenario: user attempts to use an invitation
  
  Given I am a visitor
  When I use an invitation to sign up
  Then I should see "Create Account"
  
  Scenario: user attempts to use an already redeemed invitation
  
  Given I am a visitor
  When I use an already used invitation to sign up
  Then I should see "This invitation has already been used to create an account"
